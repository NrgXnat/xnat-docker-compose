@Grapes([@Grab("org.springframework.security:spring-security-ldap:5.7.13"), @Grab("org.apache.commons:commons-lang3:3.11"), @Grab("org.slf4j:slf4j-nop:1.7.36")])

import org.apache.commons.lang3.StringUtils
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.Authentication
import org.springframework.security.core.AuthenticationException
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.security.ldap.DefaultSpringSecurityContextSource
import org.springframework.security.ldap.authentication.BindAuthenticator
import org.springframework.security.ldap.authentication.LdapAuthenticationProvider
import org.springframework.security.ldap.search.FilterBasedLdapUserSearch

final String propertiesFile = this.args.length == 0 ? "ldap.properties" : StringUtils.appendIfMissing(this.args[0], ".properties")

final Properties properties = new Properties()
def file = new File(propertiesFile)
if (file.exists()) {
    println "Loading properties from ${file.path}"
    file.withInputStream {
        properties.load it
    }
} else {
    println "No properties file found, using default values"
}

def address = properties.getProperty "address", "ldap://localhost"
def userDn = properties.getProperty "userdn", "cn=admin,dc=xnatworks,dc=io"
def password = properties.getProperty "password", "password"
def searchBase = properties.getProperty "search.base", "ou=users,dc=xnatworks,dc=io"
def searchFilter = properties.getProperty "search.filter", "(uid={0})"
def validateUsername = properties.getProperty "validate.username", "asmith"
def validatePassword = properties.getProperty "validate.password", "password"

println ""
println "Address:       ${address}"
println "Search base:   ${searchBase}"
println "Search filter: ${searchFilter}"
println "Username:      ${validateUsername}"
println "password:      ${validatePassword}"
println ""

def contextSource = new DefaultSpringSecurityContextSource(address)
contextSource.setUserDn(userDn);
contextSource.setPassword(validatePassword);
contextSource.afterPropertiesSet()

println "Validating the user account '${validateUsername}'"
BindAndAuthenticate(contextSource, searchBase, searchFilter, validateUsername, validatePassword)

private boolean BindAndAuthenticate(DefaultSpringSecurityContextSource contextSource, String searchBase, String searchFilter, username, String password) {
    println "Creating user search object with search base '${searchBase}' and filter '${searchFilter}"
    def ldapBindAuthenticator = new BindAuthenticator(contextSource)
    ldapBindAuthenticator.setUserSearch new FilterBasedLdapUserSearch(searchBase, searchFilter, contextSource)

    def provider = new LdapAuthenticationProvider(ldapBindAuthenticator)

    try {
        final Authentication authentication = provider.authenticate new UsernamePasswordAuthenticationToken(username, password)
        println "User '${authentication.principal.username}' authentication state: ${authentication.authenticated}"
        authentication.authenticated
    } catch (BadCredentialsException ignored) {
        println "Bad credentials for user '${username}'"
        false
    } catch (UsernameNotFoundException ignored) {
        println "Couldn't find user '${username}'"
        false
    } catch (AuthenticationException exception) {
        println "Some kind of authentication exception occurred for user '${username}':"
        println "${exception.class.name}: ${exception.message}"
        false
    }
}
