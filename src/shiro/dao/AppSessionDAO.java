package shiro.dao;

import java.io.IOException;
import java.io.Serializable;
import java.util.HashMap;
import java.util.List;

import org.apache.shiro.authc.UsernamePasswordToken;

import das.orm.ORMFacade;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AppSessionDAO implements Serializable, AppSessionMapper {

	private static final long serialVersionUID = -786479315710937203L;
    private final Logger log = LoggerFactory.getLogger(this.getClass());

	public AppSessionDAO() {
        log.trace(">>> constructor >>>");
	}

	@Override
	public String login(HashMap<String, String> cred) throws Exception {
        log.trace(">>> login");
        ORMFacade orm = new ORMFacade();
        try {
            log.trace("before orm.getMapper(AppUserMapper)");
            AppSessionMapper mapper = orm.getMapper(AppSessionMapper.class);
        	log.trace("before mapper.login("+cred+")");
        	String sessId = mapper.login(cred);
            log.trace("after mapper.login(cred)");
            orm.commit();
            log.trace("<<< login");
            return sessId;
        } catch (Exception e) {
            log.error("", e);
            orm.rollback();
            throw e;
        } finally {
            orm.closeDBSession();
        }
	}

	@Override
	public AppSession getSessionByID(String sessionId) throws Exception {
        log.trace(">>> getSessionByID");
        ORMFacade orm = new ORMFacade();
        try {
            log.trace("before orm.getMapper(AppUserMapper)");
            AppSessionMapper mapper = orm.getMapper(AppSessionMapper.class);
        	log.trace("before mapper.sessionById("+sessionId+")");
        	AppSession sess = mapper.getSessionByID(sessionId);
            log.trace("after mapper.sessionById(sessionId)");
            orm.commit();
            log.trace("<<< getSessionByID");
            return sess;
        } catch (Exception e) {
            log.error("", e);
            orm.rollback();
            throw e;
        } finally {
            orm.closeDBSession();
        }
	}

	@Override
	public void logout(AppSession session) throws Exception {
        log.trace(">>> logout");
        ORMFacade orm = new ORMFacade();
        try {
        	AppSessionMapper mapper = orm.getMapper(AppSessionMapper.class);
            mapper.logout(session);
            orm.commit();
            log.trace("<<< logout");
        } catch (Exception e) {
            log.error("", e);
            orm.rollback();
            throw e;
        } finally {
            orm.closeDBSession();
        }
	}

	@Override
	public List<AppUserRole> getRoles() throws IOException {
        log.trace(">>> getRoles");
        ORMFacade orm = new ORMFacade();
        try {
        	AppSessionMapper mapper = orm.getMapper(AppSessionMapper.class);
            List<AppUserRole> res = mapper.getRoles();
            log.trace("<<< getRoles");
            return res;
        } catch (IOException e) {
            log.error("", e);
            throw e;
        } finally {
            orm.closeDBSession();
        }
	}

	@Override
	public List<AppUserPermission> getPermissions() throws IOException {
        log.trace(">>> getPermissions");
        ORMFacade orm = new ORMFacade();
        try {
        	AppSessionMapper mapper = orm.getMapper(AppSessionMapper.class);
            List<AppUserPermission> res = mapper.getPermissions();
            log.trace("<<< getPermissions");
            return res;
        } catch (IOException e) {
            log.error("", e);
            throw e;
        } finally {
            orm.closeDBSession();
        }
	}
    
}
