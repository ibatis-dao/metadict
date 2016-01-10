package das.base;

import java.io.IOException;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import das.orm.ORMFacade;

public class CRUDSingleDAO<B,M extends CRUDSingleMapper<B>> implements CRUDSingleMapper<B>{

    private Class<M> m;
    protected final Logger log = LoggerFactory.getLogger(this.getClass());

    public CRUDSingleDAO(Class<M> mapperClass) {
        log.trace(">>> constructor >>>");
        m = mapperClass;
	}

	@Override
	public List<B> getAll() throws IOException {
        log.trace(">>> getAll");
        ORMFacade orm = new ORMFacade();
        try {
        	M mapper = orm.getMapper(m);
            List<B> res = mapper.getAll();
            log.trace("<<< getAll");
            return res;
        } catch (IOException e) {
            log.error(null, e);
            throw e;
        } finally {
            orm.closeDBSession();
        }
	}

	@Override
	public int insert(B item) throws IOException {
        log.trace(">>> insert");
        int res = 0;
        ORMFacade orm = new ORMFacade();
        try {
        	M mapper = orm.getMapper(m);
            res = mapper.insert(item);
            orm.commit();
            log.trace("<<< insert");
        } catch (IOException e) {
            log.error(null, e);
            orm.rollback();
            throw e;
        } finally {
            orm.closeDBSession();
        }
		return res;
	}

	@Override
	public int update(B item) throws IOException {
        log.trace(">>> update");
        int res = 0;
        ORMFacade orm = new ORMFacade();
        try {
        	M mapper = orm.getMapper(m);
            res = mapper.update(item);
            orm.commit();
            log.trace("<<< update");
        } catch (IOException e) {
            log.error(null, e);
            orm.rollback();
            throw e;
        } finally {
            orm.closeDBSession();
        }
		return res;
	}

	@Override
	public int delete(B item) throws IOException {
        log.trace(">>> delete");
        int res = 0;
        ORMFacade orm = new ORMFacade();
        try {
        	M mapper = orm.getMapper(m);
            res = mapper.delete(item);
            orm.commit();
            log.trace("<<< delete");
        } catch (IOException e) {
            log.error(null, e);
            orm.rollback();
            throw e;
        } finally {
            orm.closeDBSession();
        }
		return res;
	}

}
