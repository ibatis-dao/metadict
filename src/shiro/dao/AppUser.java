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
package shiro.dao;

import java.io.Serializable;
import java.util.Locale;
import java.util.TimeZone;

import app.person.PersonIndividual;

public class AppUser implements Serializable {

    private static final long serialVersionUID = 8030875135429404808L;
    
    private String id;			// идентификатор пользователя
    private String name;		// имя (ник/логин) пользователя
    private String passwd;		// пароль
    private Locale locale;		// страна и язык пользователя
    private TimeZone timeZone;	// часовой пояс пользователя
    private PersonIndividual person; //TODO: добавить поддержку
    
    public AppUser() {
        this(null, null);
    }
    
    public AppUser(String id, String name) {
        this(id, name, null, null);
    }
    
    public AppUser(String id, String name, Locale locale) {
        this(id, name, locale, null);
    }
    
    public AppUser(String id, String name, TimeZone timeZone) {
        this(id, name, null, timeZone);
    }
    
    public AppUser(String id, String name, Locale locale, TimeZone timeZone) {
        this.id = id;
        this.name = name;
        this.locale = locale;
        this.timeZone = timeZone;
    }
    
    public String getId() { 
    	return id;  
    }
    
    public void setId(String id) { 
    	this.id = id;
    }
    /*
    public void setId(String id) { 
    	this.id = BigInteger.valueOf(Long.valueOf(id));
    }
    */
    public String getName() { 
    	return name; 
    }
    
    public void setName(String name) { 
    	this.name = name; 
    }
    
    public String getPasswd() {
		return passwd;
	}

	public void setPasswd(String passwd) {
		this.passwd = passwd;
	}

	@Override
    public String toString() {
        return "Id="+id+", Name="+name;
    }

	/**
	 * @return the locale
	 */
	public Locale getLocale() {
		return locale;
	}

	/**
	 * @param locale the locale to set
	 */
	public void setLocale(Locale locale) {
		this.locale = locale;
	}
    
	/**
	 * @return the timeZone
	 */
	public TimeZone getTimeZone() {
		return timeZone;
	}

	/**
	 * @param timeZone the timeZone to set
	 */
	public void setTimeZone(TimeZone timeZone) {
		this.timeZone = timeZone;
	}

}
