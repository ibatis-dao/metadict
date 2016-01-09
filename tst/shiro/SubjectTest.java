package shiro;

import static org.junit.Assert.*;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.IncorrectCredentialsException;
import org.apache.shiro.authc.LockedAccountException;
import org.apache.shiro.authc.UnknownAccountException;
import org.apache.shiro.authc.UsernamePasswordToken;
import org.apache.shiro.config.IniSecurityManagerFactory;
import org.apache.shiro.mgt.SecurityManager;
import org.apache.shiro.session.Session;
import org.apache.shiro.subject.Subject;
import org.apache.shiro.util.Factory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SubjectTest {

	// tests for org.apache.shiro.subject.Subject

	private static final String username = "user01";
	private static final String password = "pa$Sword01";
	private static final UsernamePasswordToken token = new UsernamePasswordToken(username, password);
	private static final Factory<SecurityManager> factory = new IniSecurityManagerFactory("classpath:shiro.ini");
	private static final SecurityManager securityManager = factory.getInstance();
	
	private static final transient Logger log = LoggerFactory.getLogger(SubjectTest.class);

	@Before
	public void setUp() throws Exception {
	    SecurityUtils.setSecurityManager(securityManager);
	}

	@After
	public void tearDown() throws Exception {
	}

	//@Test
	public void testGetPrincipal() {
		fail("Not yet implemented");
	}

	//@Test
	public void testGetPrincipals() {
		fail("Not yet implemented");
	}

	//@Test
	public void testIsPermittedString() {
		fail("Not yet implemented");
	}

	//@Test
	public void testIsPermittedPermission() {
		fail("Not yet implemented");
	}

	//@Test
	public void testIsPermittedStringArray() {
		fail("Not yet implemented");
	}

	//@Test
	public void testIsPermittedListOfPermission() {
		fail("Not yet implemented");
	}

	//@Test
	public void testIsPermittedAllStringArray() {
		fail("Not yet implemented");
	}

	//@Test
	public void testIsPermittedAllCollectionOfPermission() {
		fail("Not yet implemented");
	}

	//@Test
	public void testCheckPermissionString() {
		fail("Not yet implemented");
	}

	//@Test
	public void testCheckPermissionPermission() {
		fail("Not yet implemented");
	}

	//@Test
	public void testCheckPermissionsStringArray() {
		fail("Not yet implemented");
	}

	//@Test
	public void testCheckPermissionsCollectionOfPermission() {
		fail("Not yet implemented");
	}

	//@Test
	public void testHasRole() {
		fail("Not yet implemented");
	}

	//@Test
	public void testHasRoles() {
		fail("Not yet implemented");
	}

	//@Test
	public void testHasAllRoles() {
		fail("Not yet implemented");
	}

	//@Test
	public void testCheckRole() {
		fail("Not yet implemented");
	}

	//@Test
	public void testCheckRolesCollectionOfString() {
		fail("Not yet implemented");
	}

	//@Test
	public void testCheckRolesStringArray() {
		fail("Not yet implemented");
	}

	@Test
	public void testLogin() {
		log.info(">> testLogin");
		Subject currentUser = SecurityUtils.getSubject();
		assertNotNull(currentUser);
		log.info(">> before login()");
		currentUser.login(token);
		log.info(">> before getSession()");
		Session session = currentUser.getSession();
		log.info("session.id="+session.getId());
		log.info(">> before isAuthenticated()");
		assertTrue(currentUser.isAuthenticated());
		log.info(">> before logout()");
		currentUser.logout();
		log.info("<< testLogin");
	}

	@Test
	public void testIsAuthenticated() {
		log.info(">> testIsAuthenticated");
		Subject currentUser = SecurityUtils.getSubject();
		assertNotNull(currentUser);
		log.info(">> before logout()");
		currentUser.logout();
		log.info(">> before isAuthenticated()");
		assertFalse(currentUser.isAuthenticated());
		log.info(">> before login(token)");
		currentUser.login(token);
		log.info(">> before isAuthenticated()");
		assertTrue(currentUser.isAuthenticated());
		log.info(">> before logout()");
		currentUser.logout();
	}

	//@Test
	public void testIsRemembered() {
		fail("Not yet implemented");
	}

	//@Test
	public void testGetSession() {
		fail("Not yet implemented");
	}

	//@Test
	public void testGetSessionBoolean() {
		fail("Not yet implemented");
	}

	//@Test
	public void testLogout() {
		fail("Not yet implemented");
	}

	//@Test
	public void testExecuteCallableOfV() {
		fail("Not yet implemented");
	}

	//@Test
	public void testExecuteRunnable() {
		fail("Not yet implemented");
	}

	//@Test
	public void testAssociateWithCallableOfV() {
		fail("Not yet implemented");
	}

	//@Test
	public void testAssociateWithRunnable() {
		fail("Not yet implemented");
	}

	//@Test
	public void testRunAs() {
		fail("Not yet implemented");
	}

	//@Test
	public void testIsRunAs() {
		fail("Not yet implemented");
	}

	//@Test
	public void testGetPreviousPrincipals() {
		fail("Not yet implemented");
	}

	//@Test
	public void testReleaseRunAs() {
		fail("Not yet implemented");
	}

	@Test
	public void integralTest() {
        log.info(">> integralTest()");
        Factory<SecurityManager> factory = new IniSecurityManagerFactory("classpath:shiro.ini");
        SecurityManager securityManager = factory.getInstance();
        SecurityUtils.setSecurityManager(securityManager);
        // get the currently executing user:
        Subject currentUser = SecurityUtils.getSubject();
        log.info("User [" + currentUser.getPrincipal() + "] is logged in :" + currentUser.isAuthenticated());
        // Do some stuff with a Session (no need for a web or EJB container!!!)
        Session session = currentUser.getSession();
        session.setAttribute("someKey", "aValue");
        String value = (String) session.getAttribute("someKey");
        if (value.equals("aValue")) {
            log.info("Retrieved the correct value! [" + value + "]");
        }

        // let's login the current user so we can check against roles and permissions:
        if (!currentUser.isAuthenticated()) {
            UsernamePasswordToken token = new UsernamePasswordToken(username, password);
            //token.setRememberMe(true);
            try {
                currentUser.login(token);
            } catch (UnknownAccountException uae) {
                log.info("There is no user with username of " + token.getPrincipal());
            } catch (IncorrectCredentialsException ice) {
                log.info("Password for account " + token.getPrincipal() + " was incorrect!");
            } catch (LockedAccountException lae) {
                log.info("The account for username " + token.getPrincipal() + " is locked.  " +
                        "Please contact your administrator to unlock it.");
            }
            // ... catch more exceptions here (maybe custom ones specific to your application?
            catch (AuthenticationException ae) {
                //unexpected condition?  error?
            	log.error("", ae);
            }
        }
        
        //say who they are:
        //print their identifying principal (in this case, a username):
        log.info("User [" + currentUser.getPrincipal() + "] is logged in : " + currentUser.isAuthenticated());
        
        //test a role:
        if (currentUser.hasRole("admin")) {
            log.info("You are admin");
        } else {
            log.info("You are unprivileged user");
        }
        
        //test a typed permission (not instance-level)
        if (currentUser.isPermitted("lightsaber:weild")) {
            log.info("You may use a lightsaber ring.  Use it wisely.");
        } else {
            log.info("Sorry, lightsaber rings are for schwartz masters only.");
        }

        //a (very powerful) Instance Level permission:
        if (currentUser.isPermitted("winnebago:drive:eagle5")) {
            log.info("You are permitted to 'drive' the winnebago with license plate (id) 'eagle5'.  " +
                    "Here are the keys - have fun!");
        } else {
            log.info("Sorry, you aren't allowed to drive the 'eagle5' winnebago!");
        }
		
        //all done - log out!
        currentUser.logout();
        log.info("<< integralTest()");
	}

}
