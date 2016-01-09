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
package das.dao.filter;

import das.orm.ORMFacade;
import das.excpt.EArgumentBreaksRule;
import das.excpt.ENullArgument;
import java.io.IOException;
import java.text.MessageFormat;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class Filter implements ISqlFilterable {

    protected final Logger log = LoggerFactory.getLogger(this.getClass()); 
    private final ORMFacade dao;
    private String sqlTemplate;
    private Object[] args;
    private int argCount;

    protected Filter(int argCount) throws IOException {
        this.argCount = argCount;
        this.dao = new ORMFacade();
        this.sqlTemplate = loadSqlTemplate();
        log.debug(">>> Filter.constructor. argCount="+argCount+", sqlTemplate="+sqlTemplate);
    }
    
    protected ORMFacade getDao() throws IOException {
        return dao;
    }

    @Override
    public String getFilterSqlText() {
        return format(sqlTemplate, args);
    }

    @Override
    public String toString() {
        return getFilterSqlText();
    }
    
    protected String format(String pattern, Object... arguments) {
        return MessageFormat.format(pattern, arguments);
    }

    public String getSqlTemplate() {
        return sqlTemplate;
    }

    private String loadSqlTemplate() throws IOException {
        if (getDao() == null) {
            throw new ENullArgument("loadSqlTemplate", "getDao()");
        }
        sqlTemplate = getDao().getSQLFragment(getClass().getSimpleName());
        return sqlTemplate;
    }
    
    /**
     * @return the args
     */
    public Object[] getArgs() {
        return args;
    }

    /**
     * @param args the args to set
     */
    public void setArgs(Object[] args) {
        if (((args == null) && (argCount != 0)) || ((args != null) && (args.length != argCount))) {
            throw new EArgumentBreaksRule("setArgs", "args.length == argCount");
        }
        this.args = args;
    }

    /**
     * @param arg the arg to set
     */
    protected void setOneArg(Object arg) {
        setArgs(new Object[]{arg});
    }

    public int getArgCount() {
        return argCount;
    }

    protected void setArgCount(int argCount) {
        this.argCount = argCount;
    }

////////////////////////////////////////////////////////////////////////////

public static class And extends Filter {
    
    public And(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    
}

public static class Between extends Filter {
    
    public Between(Object... arg) throws IOException {
        super(3);
        setArgs(arg);
    }
    }

public static class Equals extends Filter {
    
    public Equals(Object... arg) throws IOException {
        super(2);
        log.debug(">>> Equals.constructor");
        setArgs(arg);
    }
    
}

public static class NotEquals extends Filter {
    
    public NotEquals(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    }

public static class Greater extends Filter {
    
    public Greater(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    }

public static class GreaterOrEquals extends Filter {
    
    public GreaterOrEquals(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    }

public static class IsNull extends Filter {

    public IsNull(Object arg) throws IOException {
        super(1);
        setOneArg(arg);
    }
    
}

public static class IsNotNull extends Filter {
    
    public IsNotNull(Object... arg) throws IOException {
        super(1);
        setArgs(arg);
    }
    }

public static class Less extends Filter {
    
    public Less(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    }

public static class LessOrEquals extends Filter {
    
    public LessOrEquals(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    }

public static class Like extends Filter {
    
    public Like(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    }

public static class NotLike extends Filter {
    
    public NotLike(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    }

public static class Not extends Filter {
    
    public Not(Object arg) throws IOException {
        super(1);
        setOneArg(arg);
    }
    
}

public static class Or extends Filter {
    
    public Or(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    
}

public static class Containing extends Filter {
    
    public Containing(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    
}

public static class StartsWith extends Filter {
    
    public StartsWith(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    
}

public static class EndsWith extends Filter {
    
    public EndsWith(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    
}

public static class In extends Filter {
    
    public In(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    
}

public static class NotIn extends Filter {
    
    public NotIn(Object... arg) throws IOException {
        super(2);
        setArgs(arg);
    }
    
}

public static class Exists extends Filter {
    
    public Exists(Object... arg) throws IOException {
        super(1);
        setArgs(arg);
    }
    
}

public static class NotExists extends Filter {
    
    public NotExists(Object... arg) throws IOException {
        super(1);
        setArgs(arg);
    }
    
}

}
