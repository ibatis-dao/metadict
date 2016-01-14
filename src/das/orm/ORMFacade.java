/*
 * Copyright 2015 serg.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package das.orm;

import das.dao.props.BeanPropertyMapping;
import das.excpt.ENullArgument;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

import org.apache.ibatis.session.Configuration;
import org.apache.ibatis.session.SqlSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

import org.apache.ibatis.exceptions.PersistenceException;
import org.apache.ibatis.mapping.Environment;
import org.apache.ibatis.parsing.XNode;

public class ORMFacade {

    protected static final Logger log = LoggerFactory.getLogger(ORMFacade.class);
    private static ORMBackendConnector ormConn = null;
    private SqlSession sqlSess; 

    public ORMFacade() throws IOException, PersistenceException {
        log.trace(">>> constructor");
        createDaoFactory();
    }

    private void createDaoFactory() throws IOException, PersistenceException {
        log.trace(">>> createDaoFactory");
        synchronized(this) {
            if (ormConn == null) {
                try {
                    ormConn = new ORMBackendConnector(null);
                } catch (IOException e ) {
                    log.error("createDaoFactory() failed", e);
                    throw e;
                }
	            catch (PersistenceException e ) {
	                log.error("createDaoFactory() failed", e);
	                throw e;
	            }
            }
        }
    }

    public SqlSession createDBSession(){
        log.trace(">>> createDBSession");
        if (ormConn == null) { sqlSess = null; }
        else { sqlSess = ormConn.createDBSession(); }
        return sqlSess;
    }

    public SqlSession getDBSession(){
        log.trace(">>> getDBSession");
        if (sqlSess == null) {
            return createDBSession();
        }
        else {
            return sqlSess;
        }
    }

    public void closeDBSession(){
        log.trace(">>> closeDBSession. session="+sqlSess);
        if (sqlSess != null) { sqlSess.close(); }
        sqlSess = null;
    }

    public <T extends Object> T getMapper(Class<T> type) {
        log.trace(">>> getMapper");
        return getDBSession().getMapper(type);
    }

    public Connection getDBConnection(){
        log.trace(">>> getDBConnection");
        return getDBSession().getConnection();
    }

    public Configuration getConfiguration() throws IOException {
        log.trace(">>> getConfiguration");
        if (ormConn == null) { createDaoFactory(); }
        return ormConn.getConfiguration();
    }
    
    public List<BeanPropertyMapping> getBeanPropertiesMapping(Class<?> beanClass) throws IOException {
        log.trace(">>> getBeanPropertiesMapping");
        if (ormConn == null) { createDaoFactory(); }
        return ormConn.getBeanPropertiesMapping(beanClass);
    }

    public void commit(){
        log.trace(">>>  commit(); session="+sqlSess);
        if (sqlSess != null) { sqlSess.commit(); }
    }

    public void rollback(){
        log.trace(">>> rollback(); session="+sqlSess);
        if (sqlSess != null) { sqlSess.rollback(); }
    }

    public String getDatabaseId() throws IOException {
        log.trace(">>> getDatabaseId");
        Configuration conf = getConfiguration();
        return conf.getDatabaseId();
    }
    
    public String getEnvironmentId() throws IOException {
        log.trace(">>> getEnvironmentId");
        Configuration conf = getConfiguration();
        Environment env = conf.getEnvironment();
        return env.getId();
    }
    
    public String getSQLFragment(String ID) throws IOException {
        String mthdName = "getSQLFragment";
        log.trace(mthdName);
        Configuration conf = getConfiguration();
        if (conf != null) {
            //log.debug("conf != null");
            Map<String, XNode> sqlNodes = conf.getSqlFragments();
            if (sqlNodes != null) {
                //log.debug("sqlNodes != null");
                /*
                for (Map.Entry<String, XNode> es : sqlNodes.entrySet()) {
                    XNode node = es.getValue();
                    log.debug("node.key="+es.getKey()+", node.name="+node.getName()
                        +", node.path="+node.getPath()+", node.body="+node.getStringBody()
                        +", node.toString="+node.toString()
                        +", node.Attribute="+node.getStringAttribute("lang"));
                }
                */
                /*
                node.key=fxapp01.dao.filter.FilterMapper.And, node.name=sql, node.path=mapper/sql, node.body=({0}) and ({1}), node.toString=<sql databaseId="oracle" id="And">({0}) and ({1})</sql>
                node.key=And, node.name=sql, node.path=mapper/sql, node.body=({0}) and ({1}), node.toString=<sql databaseId="oracle" id="And">({0}) and ({1})</sql>
                */
                XNode node = sqlNodes.get(ID);
                if (node != null) {
                    //log.debug("node != null");
                    //evalString(String expression)
                    //getStringBody()
                    //toString()
                    return node.getStringBody();
                } else {
                    //log.debug("node == null");
                    return null;
                }
            } else {
                throw new ENullArgument(mthdName, "getSqlFragments()");
            }
        } else {
            throw new ENullArgument(mthdName, "getConfiguration()");
        }
    }
    
    public void setSqlTypeForClass(String sqlTypeName, Class<?> javaClass) {
    	ormConn.setSqlTypeForClass(sqlTypeName, javaClass);
    }
    
    public String getSqlTypeForClass(Class<?> javaClass) {
    	return ormConn.getSqlTypeForClass(javaClass);
    }
    
    public Class<?> getClassForSqlType(String sqlTypeName) {
    	return ormConn.getClassForSqlType(sqlTypeName);
    }
}
