require 'rack/lobster'
require 'ldap'

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
    ldap = LDAP::Conn.new(HOST, LDAP::LDAP_PORT.to_i)
    ldap.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
    ldap
  end

  def ldap_user_by_uid(uid)
    user = nil
    ldap = ldap_connect
    ldap.bind do
      ldap.search(BASE_DN, LDAP::LDAP_SCOPE_SUBTREE, "(uid=#{uid})", ATTRS) do |entry|
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
