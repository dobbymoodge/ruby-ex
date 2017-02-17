require 'rack/lobster'
require 'net/ldap'

HOST        = 'ldap.rdu.redhat.com'
BASE_DN     = 'ou=Users, dc=redhat, dc=com'
ATTRS = ['uid', 'mail', 'cn']


map '/health' do
  health = proc do |env|
    [200, { "Content-Type" => "text/html" }, ["1"]]
  end
  run health
end

map '/lobster' do
  run Rack::Lobster.new
end

map '/ldap' do
  def ldap_connect
    ldap = Net::LDAP.new(host: HOST, port: 389)
    ldap
  end

  def ldap_user_by_uid(uid)
    user = nil
    ldap = ldap_connect
    if ldap.bind
      ldap.search(base: BASE_DN, scope: Net::LDAP::SearchScope_WholeSubtree, filter: "(uid=#{uid})", attribute: ATTRS) do |entry|
        #email = entry.vals('mail')[0]
        user = entry
      end
    end
    user
  end

  lookup = proc do |env|
    [200, { "Content-Type" => "text/html" }, [ "#{ldap_user_by_uid('jolamb').dn}" ]]
  end
  run lookup
end

map '/' do
  welcome = proc do |env|
    [200, { "Content-Type" => "text/html" }, [<<WELCOME_CONTENTS
howdy
WELCOME_CONTENTS
    ]]
  end
  run welcome
end
