package shiro.dao;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.TimeZone;

public class AppSession implements Serializable {

	private static final long serialVersionUID = 4485025269463356639L;
    private String id;				// идентификатор токена
    private String localTokenValue;	// локализованное (уникальное) значение токена
    private String originTokenValue;// исходное оригинальное значение токена, полученное от источника аутентификации
    private String sessionId;		// идентификатор сессии
    //auth_path_id // источник аутентификации
    private Calendar whenStarted;	// дата / время начала сессии
    private Calendar whenLastActive;// дата / время последней активности сессии
    private String userId;			// идентификатор пользователя
    /*
    private Locale locale;			// страна и язык пользователя в текущей сессии
    private TimeZone timeZone;		// часовой пояс пользователя в текущей сессии
    private String appInfo;			// информация о приложении, его окружении (н-р, продуктивное/тестовое), о версии ПО и т.п.
    private String serverInfo;		// информация о сервере, о версии ПО и т.п.
    private String clientInfo;		// информация о месте подключения, о соединении, о версии клиентского ПО, браузера и т.п.
    */
    private List<AppUserRole> roles;// список ролей в этой сессии
    private List<AppUserPermission> permissions; // список разрешений (полномочий на объекты и действия)

	public AppSession() {
		this(null, null, null, null);
	}

	public AppSession(String localTokenValue, String userId) {
		this(localTokenValue, userId, null, null);
	}

    public AppSession(String localTokenValue, String userId, List<AppUserRole> roles, List<AppUserPermission> permissions) {
        this.localTokenValue = localTokenValue;
        this.whenStarted = Calendar.getInstance();
        this.whenLastActive = Calendar.getInstance();
        this.userId = userId;
        this.roles = roles;
        this.permissions = permissions;
    }
    
	@Override
	public String toString() {
		return "id="+id+", localTokenValue="+localTokenValue+", originTokenValue="+originTokenValue+
			", sessionId="+sessionId+", userId="+userId+
			", whenStarted="+whenStarted.getTime()+", whenLastActive="+whenLastActive.getTime();
	}
	
    /**
	 * @return the id of application session
	 * идентификатор сессии приложения
	 */
	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	/**
	 * @return the userId
	 * идентификатор пользователя / субъекта
	 */
	public String getUserId() {
		return userId;
	}

	/**
	 * @param userId the userId to set
	 * идентификатор пользователя / субъекта
	 */
	public void setUserId(String userId) {
		this.userId = userId;
	}

	public List<AppUserRole> getRoles() {
		if (roles == null) {
			roles = new ArrayList<AppUserRole>();
		}
		return roles;
	}

	public void setRoles(List<AppUserRole> roles) {
		this.roles = roles;
	}

	public Set<String> getRoleNames() {
		Set<String> roleNames = new HashSet<String>();
		for (AppUserRole role : getRoles()) {
			roleNames.add(role.getName());
		}
		return roleNames;
	}

	public List<AppUserPermission> getPermissions() {
		if (permissions == null) {
			permissions = new ArrayList<AppUserPermission>();
		}
		return permissions;
	}

	public void setPermissions(List<AppUserPermission> permissions) {
		this.permissions = permissions;
	}

	public Set<String> getPermissionNames() {
		Set<String> permissionNames = new HashSet<String>();
		for (AppUserPermission perm : getPermissions()) {
			permissionNames.add(perm.getId());
		}
		return permissionNames;
	}

	/**
	 * @return the whenStarted
	 * дата / время начала сессии
	 */
	public Calendar getWhenStarted() {
		return whenStarted;
	}

	/**
	 * @param whenStarted the whenStarted to set
	 * дата / время начала сессии
	 */
	public void setWhenStarted(Calendar whenStarted) {
		this.whenStarted = whenStarted;
	}

	/**
	 * @return the whenLastActive
	 * дата / время последней активности сессии
	 */
	public Calendar getWhenLastActive() {
		return whenLastActive;
	}

	/**
	 * @param whenLastActive the whenLastActive to set
	 * дата / время последней активности сессии
	 */
	public void setWhenLastActive(Calendar whenLastActive) {
		this.whenLastActive = whenLastActive;
	}
	
	/**
	 * обновление времени последней активности сессии.
	 * должна вызываться при любых действиях в сессии
	 */
	public void refreshLastActive() {
		this.whenLastActive = Calendar.getInstance();
	}

	/**
	 * @return the localTokenValue
	 */
	public String getLocalTokenValue() {
		return localTokenValue;
	}

	/**
	 * @param localTokenValue the localTokenValue to set
	 */
	public void setLocalTokenValue(String localTokenValue) {
		this.localTokenValue = localTokenValue;
	}

	/**
	 * @return the originTokenValue
	 */
	public String getOriginTokenValue() {
		return originTokenValue;
	}

	/**
	 * @param originTokenValue the originTokenValue to set
	 */
	public void setOriginTokenValue(String originTokenValue) {
		this.originTokenValue = originTokenValue;
	}

	/**
	 * @return the sessionId
	 */
	public String getSessionId() {
		return sessionId;
	}

	/**
	 * @param sessionId the sessionId to set
	 */
	public void setSessionId(String sessionId) {
		this.sessionId = sessionId;
	}

}
