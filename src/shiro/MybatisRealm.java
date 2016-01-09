package shiro;

import java.util.HashMap;
import java.util.List;
import java.util.Set;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.AccountException;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.AuthenticationInfo;
import org.apache.shiro.authc.AuthenticationToken;
import org.apache.shiro.authc.SimpleAuthenticationInfo;
import org.apache.shiro.authc.UsernamePasswordToken;
import org.apache.shiro.authc.credential.AllowAllCredentialsMatcher;
import org.apache.shiro.authc.credential.CredentialsMatcher;
import org.apache.shiro.authz.AuthorizationException;
import org.apache.shiro.authz.AuthorizationInfo;
import org.apache.shiro.authz.SimpleAuthorizationInfo;
import org.apache.shiro.realm.AuthorizingRealm;
import org.apache.shiro.subject.PrincipalCollection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import shiro.dao.AppSession;
import shiro.dao.AppSessionDAO;
import shiro.dao.AppSessionMapper;
import shiro.dao.AppUserPermission;
import shiro.dao.AppUserRole;

//TODO создать аналог org.apache.shiro.web.env.IniWebEnvironment, который будет брать настройки не из ini-файла, а из БД,
//чтобы можно было добавлять роли без остановки приложения

public class MybatisRealm extends AuthorizingRealm {

    private final Logger log = LoggerFactory.getLogger(this.getClass());
    private static final String sessionAttribute = "appSession"; 
    private boolean isAuthenticationAllowed = true; // управляет ли этот реалм аутентификацией 
    private boolean isAuthorizationAllowed = true;  // управляет ли этот реалм авторизацией
    
	@Override
	protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token) throws AuthenticationException {
		SimpleAuthenticationInfo info = null;
		log.trace(">> doGetAuthenticationInfo. isAuthenticationAllowed="+isAuthenticationAllowed);
		if (isAuthenticationAllowed) {
	        if (token == null) {
	        	// shiro, по идее, не должна допускать этого
	            throw new AccountException("Null AuthenticationToken not allowed");
	        }
	        if (! (token instanceof UsernamePasswordToken)) {
	        	// это проблемы с конфигурацией. сюда должны попадать только запросы аутентификации по логину/паролю
	            throw new AccountException("AuthenticationToken expected to be subclass of UsernamePasswordToken");
	        }
			UsernamePasswordToken upToken = (UsernamePasswordToken) token;
	        String username = upToken.getUsername();
	        String password = new String(upToken.getPassword());
	        // Null username is invalid
	        if (username == null) {
	            throw new AccountException("Null username not allowed.");
	        }
            //log.debug("User=" + username + ", pass="+password+", host="+upToken.getHost());
	        
        	HashMap<String, String> cred = new HashMap<String, String>();
	        try {
	        	cred.put("username", username);
	        	cred.put("password", password);
	        	cred.put("host", upToken.getHost());
	        	AppSessionMapper dao = new AppSessionDAO();
	        	String appSessionID = dao.login(cred);
	        	AppSession appSession = dao.getSessionByID(appSessionID);
	        	log.debug("appSession="+appSession.toString());
	    		// prevents shiro from password checking. actual password verification made by dao.login()
	            CredentialsMatcher cm = getCredentialsMatcher();
	            if ((cm == null) || (cm != null && cm.getClass() != AllowAllCredentialsMatcher.class)) {
	            	setCredentialsMatcher(new AllowAllCredentialsMatcher());
	            }
	            SecurityUtils.getSubject().getSession().setAttribute(sessionAttribute, appSession);
	        } catch (Exception e) {
	            final String message = "Error while authenticating user [" + username + "]";
	            log.error(message, e);
	            // Rethrow any errors as an authentication exception
	            throw new AuthenticationException(message, e);
	        }
	
	        info = new SimpleAuthenticationInfo(username, password.toCharArray(), getName());
        }
        return info;
	}

	@Override
	protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
		SimpleAuthorizationInfo info = null;
		log.trace(">> doGetAuthorizationInfo. authorizationAllowed="+isAuthorizationAllowed);
		if (isAuthorizationAllowed) {
			//null usernames are invalid
	        if (principals == null) {
	            throw new AuthorizationException("PrincipalCollection method argument cannot be null.");
	        }
	
	        String username = (String) getAvailablePrincipal(principals);
	
	        AppSessionMapper dao = null;
	        AppSession appSession = null;
	        Set<String> roleNames = null;
	        Set<String> permissions = null;
	        try {
	        	appSession = (AppSession)SecurityUtils.getSubject().getSession().getAttribute(sessionAttribute);
	        	if (appSession == null) {
	        		throw new AuthorizationException("appSession = null while doGetAuthorizationInfo(). user not authenticated");
	        	}
        		log.debug("authenticated. appSession != null");
	        	if (appSession.getRoles().isEmpty() || appSession.getPermissions().isEmpty()) {
	        		log.debug("user has no cached roles or permissions. about to load them");
		        	// Retrieve roles and permissions from database
		            if (dao == null) { 
		            	dao = new AppSessionDAO();
		            }
		            if (appSession.getRoles().isEmpty()) {
		                List<AppUserRole> roles = dao.getRoles();
		                appSession.setRoles(roles); 
		            }
		            if (appSession.getPermissions().isEmpty()) {
			            List<AppUserPermission> perms = dao.getPermissions();
			            appSession.setPermissions(perms);
		            }
	        	}
	            
	            roleNames = appSession.getRoleNames();
	            permissions = appSession.getPermissionNames();
		        log.debug("User [" + username + "], appSessionId="+appSession.getId()+", has "+
		        	roleNames.size()+" roles, "+permissions.size()+ " permissions");
	        } catch (Exception e) {
	            final String message = "There was a error while authorizing user [" + username + "]";
	            log.error(message, e);
	            // Rethrow any SQL errors as an authorization exception
	            throw new AuthorizationException(message, e);
	        }
	
	        info = new SimpleAuthorizationInfo(roleNames);
	        info.setStringPermissions(permissions);
        }
        return info;
	}

	public boolean getIsAuthenticationAllowed() {
		return isAuthenticationAllowed;
	}

	public void setIsAuthenticationAllowed(boolean isAuthenticationAllowed) {
		this.isAuthenticationAllowed = isAuthenticationAllowed;
		log.trace(">> setAuthenticationAllowed("+isAuthenticationAllowed+")");
	}

	public boolean getIsAuthorizationAllowed() {
		return isAuthorizationAllowed;
	}

	public void setIsAuthorizationAllowed(boolean isAuthorizationAllowed) {
		this.isAuthorizationAllowed = isAuthorizationAllowed;
		log.trace(">> setAuthenticationAllowed("+isAuthorizationAllowed+")");
	}

}
