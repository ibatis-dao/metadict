package shiro.dao;

import java.io.IOException;
import java.util.List;

import org.apache.shiro.authc.UsernamePasswordToken;

public interface AppSessionMapper {

	/*
	 * You can pass multiple parameters to a mapper method. If you do, they will be named by the literal
	 * "param" followed by their position in the parameter list by default, for example: #{param1},
	 * #{param2} etc. If you wish to change the name of the parameters (multiple only), then you can use
	 * the @Param("paramName") annotation on the parameter. 
	 **/

	String login(UsernamePasswordToken cred) throws Exception;
    
	AppSession getSessionByID(String sessionId) throws Exception;
    
	void logout(AppSession session) throws Exception;

	List<AppUserRole> getRoles() throws IOException;
	
	List<AppUserPermission> getPermissions() throws IOException;
    
	//List<AppUserPermission> getPermissions(AppUserRole role) throws IOException;
    
}
