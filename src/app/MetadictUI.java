package app;
/*
 * Vaadin 7 Compatibility
 * https://dev.vaadin.com/wiki/Vaadin7
 * Browsers
 *   Internet Explorer 8 and newer. For support for Internet Explorer 6 or 7, users are referred to Vaadin 6 or to the Chrome Frame plug-in.
 *   latest Firefox, Chrome, Safari and Opera major version available at the time of release Vaadin 7.
 *   iOS 5 and newer and Android 2.3 and newer.
 * Some features might work “better” or look slightly different in modern browsers than in older ones.
 * Java
 *   requires Java 6 or newer
 * Portlets
 *   Vaadin 7 does not support Portlet 1.0 (JSR-168). Users relying on JSR-168 are referred to Vaadin 6. Portlet 2.0 (JSR-286) is supported in Vaadin 7.
 * Application Servers
 *   Vaadin 7 will require the servlet container to be compatible with Servlet API 2.4 or newer. 
 *   This is compatible with the GWT requirement of Servlet 2.4 (bundled with GWT). 
 *   For server compatibility with various Servlet APIs, see table below. 
 *   All servers supported by Vaadin 6 support Servlet API 2.4 except Tomcat 4 and JBoss 3.2.
 *   Some features might only be available when using a Servlet 3.0 compatible servlet container.
 *   Server								Servlet 2.3	Servlet 2.4	Servlet 2.5	Servlet 3.0	Java6
 *   Jetty								4			5			6			8			all
 *   Apache Tomcat						4			5			6			7			all
 *   JBoss Application Server			3.2			4			5			6			all
 *   Oracle WebLogic Server				?			9			10			-			10.3
 *   IBM WebSphere Application Server	?			6			7			8			7
 *   Glassfish													2			3			all
 *   Google App Engine											yes						yes
 */

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.subject.Subject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import app.login.WebAppSession;
import app.login.ErrorView;
import app.login.LoginView;

import com.vaadin.annotations.Theme;
import com.vaadin.annotations.VaadinServletConfiguration;
import com.vaadin.navigator.Navigator;
import com.vaadin.navigator.ViewChangeListener;
import com.vaadin.navigator.ViewChangeListener.ViewChangeEvent;
import com.vaadin.server.CustomizedSystemMessages;
import com.vaadin.server.ServiceException;
import com.vaadin.server.SessionDestroyEvent;
import com.vaadin.server.SessionDestroyListener;
import com.vaadin.server.SessionInitEvent;
import com.vaadin.server.SessionInitListener;
import com.vaadin.server.SystemMessages;
import com.vaadin.server.SystemMessagesInfo;
import com.vaadin.server.SystemMessagesProvider;
import com.vaadin.server.VaadinRequest;
import com.vaadin.server.VaadinServlet;
import com.vaadin.ui.Button;
import com.vaadin.ui.Button.ClickEvent;
import com.vaadin.ui.Label;
import com.vaadin.ui.UI;
import com.vaadin.ui.VerticalLayout;

@Theme("metadict")
public class MetadictUI extends UI implements ViewChangeListener {

	private static final long serialVersionUID = 3837227642567085113L;
	private static final transient Logger log = LoggerFactory.getLogger(MetadictUI.class);

	public static class Servlet extends VaadinServlet implements SessionInitListener, SessionDestroyListener, ServletContextListener {

		private static final long serialVersionUID = -7146942064877475600L;
		private SystemMessages sysmsg = null;
		@Override
	    protected void servletInitialized() throws ServletException {
	        super.servletInitialized();
	        log.trace(">> servletInitialized");
	        getService().addSessionInitListener(this);
	        getService().addSessionDestroyListener(this);
	        getService().setSystemMessagesProvider(
	    		new SystemMessagesProvider() {
					private static final long serialVersionUID = 5269710387776287822L;

					@Override
	                public SystemMessages getSystemMessages(final SystemMessagesInfo systemMessagesInfo) {
	                	log.trace(">> getSystemMessages");
	                    if (sysmsg == null) {
	                    	sysmsg = getLocalizedSystemMessages(systemMessagesInfo);
	                    }
	                	return sysmsg;
	                }
	            });
	    }
		
		private SystemMessages getLocalizedSystemMessages(final SystemMessagesInfo systemMessagesInfo) {
        	log.trace(">> getLocalizedSystemMessages");
            CustomizedSystemMessages csm = new CustomizedSystemMessages();
            String clickOrPressESCMessage = "<u>кликните сюда</u> или нажмите ESC для продолжения.";
            String unsavedDataMessage = "Позаботьтесь о несохраненных данных, и "+clickOrPressESCMessage;
            String informAdminMessage = "Пожалуйста, сообщите об ошибке администратору.";
            //исходные тексты сообщений см. в com.vaadin.server.SystemMessages
            csm.setInternalErrorCaption("Внутренняя ошибка");
            csm.setInternalErrorMessage(informAdminMessage+"<br/>"+unsavedDataMessage);
            csm.setSessionExpiredCaption("Время сессии истекло");
            csm.setSessionExpiredMessage(unsavedDataMessage);
            //csm.setSessionExpiredNotificationEnabled(false);
            csm.setOutOfSyncCaption("Рассинхронизация");
            csm.setOutOfSyncMessage("Произошла рассинхронизация с сервером.<br/>"+clickOrPressESCMessage);
            csm.setCommunicationErrorCaption("Проблемы со связью");
            csm.setCommunicationErrorMessage(unsavedDataMessage);
            csm.setCookiesDisabledCaption("Отключены куки (cookies)");
            csm.setCookiesDisabledMessage("Это приложение не будет работать без куков (cookies).<br/>Пожалуйста, включите куки в браузере и "+clickOrPressESCMessage);
            csm.setAuthenticationErrorCaption("Ошибка аутентификации");
            csm.setAuthenticationErrorMessage(unsavedDataMessage);
            return csm;
		}

	    @Override
	    public void sessionInit(SessionInitEvent event) throws ServiceException {
	    	log.trace(">> sessionInit");
	    }

	    @Override
	    public void sessionDestroy(SessionDestroyEvent event) {
	    	log.trace(">> sessionDestroy");
	    }

		@Override
		public void contextDestroyed(ServletContextEvent arg0) {
			log.info(">> contextDestroyed");
		}

		@Override
		public void contextInitialized(ServletContextEvent arg0) {
			log.info(">> contextInitialized");
		}
	}
	
	@Override
	protected void init(VaadinRequest request) {
		log.trace(">> Init()");
		WebAppSession.getCurrent(true);
		
		/*
		final VerticalLayout layout = new VerticalLayout();
		layout.setMargin(true);
		setContent(layout);

		Button button = new Button("Click Me");
		button.addClickListener(new Button.ClickListener() {
			public void buttonClick(ClickEvent event) {
				layout.addComponent(new Label("Thank you for clicking"));
			}
		});
		layout.addComponent(button);
		*/
		Navigator navigator = new Navigator(this, this);
		navigator.addViewChangeListener(this);

		navigator.addView("", LoginView.class);
		if (SecurityUtils.getSubject().isAuthenticated()) {
			getUI().getNavigator().addView(MainView.class.getName(), MainView.class);
		}
		navigator.setErrorView(ErrorView.class);
	}

	@Override
	public boolean beforeViewChange(ViewChangeEvent event) {
		log.trace(">> beforeViewChange()");
		Subject currentUser = SecurityUtils.getSubject();
		log.debug("currentUser="+currentUser);
		//если юзер аутентифицирован и мы на странице логина, переходим в главное окно
		if (currentUser.isAuthenticated() && event.getViewName().equals("")) {
			log.debug("user is just authenticated, go to MainView");
			event.getNavigator().navigateTo(MainView.class.getName());
			return false;
		}

		//если юзер не аутентифицирован и мы не на странице логина, переходим на страницу логина
		if (!currentUser.isAuthenticated() && !event.getViewName().equals("")) {
			log.debug("user is not authenticated, go to login form");
			event.getNavigator().navigateTo("");
			return false;
		}

		log.trace("view change allowed");
		return true;
	}

	@Override
	public void afterViewChange(ViewChangeEvent event) {
		// TODO Auto-generated method stub
	}
	
}
