package app.login;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.UsernamePasswordToken;
import org.apache.shiro.subject.Subject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.vaadin.event.ShortcutAction.KeyCode;
import com.vaadin.event.ShortcutListener;
import com.vaadin.navigator.View;
import com.vaadin.navigator.ViewChangeListener.ViewChangeEvent;
import com.vaadin.server.UserError;
import com.vaadin.server.VaadinService;
import com.vaadin.ui.Alignment;
import com.vaadin.ui.Button;
import com.vaadin.ui.Button.ClickEvent;
import com.vaadin.ui.Button.ClickListener;
import com.vaadin.ui.FormLayout;
import com.vaadin.ui.Panel;
import com.vaadin.ui.PasswordField;
import com.vaadin.ui.TextField;
import com.vaadin.ui.VerticalLayout;

import app.MainView;

public class LoginView extends VerticalLayout implements View {

    /**
	 * 
	 */
	private static final long serialVersionUID = -4129421321618108808L;
	private static final transient Logger log = LoggerFactory.getLogger(LoginView.class);
	
	public LoginView() {
		log.trace(">> LoginView()");
	    SignInPanel signInPanel = new SignInPanel();
	    addComponent(signInPanel);
	    setSizeFull();
	    setSpacing(true);
	    //setMargin(true);
	    setComponentAlignment(signInPanel, Alignment.MIDDLE_CENTER);
	}

	@Override
	public void enter(ViewChangeEvent event) {
		log.trace(">> enter()");
	}

	@SuppressWarnings("serial")
	private class SignInPanel extends Panel implements ClickListener {

		private TextField username = new TextField("Логин");
		private PasswordField password = new PasswordField("Пароль");
		private Button loginBtn = new Button("Войти", this);

		public SignInPanel() {
			log.trace(">> SignInPanel()");
			//setSpacing(true);
			setSizeUndefined();
	        FormLayout frmLayout = new FormLayout();
	        /* Label label = new Label("test 123");
	        layout.addComponent(label); */
			//username.focus();
	        username.setValue("StarukhSA"); //отладка
			password.focus();
			frmLayout.addComponent(username);
			frmLayout.addComponent(password);
			frmLayout.addComponent(loginBtn);
			frmLayout.setMargin(true);
			//frmLayout.setSpacing(true);
			setContent(frmLayout);
	        addAction(new ShortcutListener("Default key", KeyCode.ENTER, null) {
	            @Override
	            public void handleAction(final Object sender, final Object target) {
	            	login();
	            }
	        });
			/*
			addAction(new ShortcutListener("Default key", KeyCode.ENTER, null) {
	            @Override
	            public void handleAction(final Object sender, final Object target) {
	                // The panel is the sender, loop trough content
	                for (final Iterator<Component> it = frmLayout.iterator(); it.hasNext();) {
	                    // target is the field we're currently in, focus the
	                    // next
	                    if (it.next() == target && it.hasNext()) {
	                        final Object next = it.next();
	                        if (next instanceof Focusable) {
	                            ((Focusable) next).focus();
	                        }
	                    }
	                }
	            }
	        });
	        */
	    }
		
		@Override
		public void buttonClick(ClickEvent event) {
			log.trace(">> buttonClick()");
			login();
		}

		private void login() {
			log.trace(">> login()");
			if ("".equalsIgnoreCase(username.getValue())) { 
				username.setComponentError(new UserError("Имя пользователя не может быть пустым"));
				return;
			} else {
				username.setComponentError(null);
			}
			/* ОТЛАДКА !!!
			if ("".equalsIgnoreCase(password.getValue())) { 
				password.setComponentError(new UserError("Пароль пользователя не может быть пустым"));
				return;
			} else {
				password.setComponentError(null);
			}
			*/
			Subject currentUser = SecurityUtils.getSubject();
			UsernamePasswordToken token = new UsernamePasswordToken(username.getValue(), password.getValue());
			try {
				currentUser.login(token);
				username.setComponentError(null);
				password.setComponentError(null);
				getUI().getNavigator().addView(MainView.class.getName(), MainView.class);
				getUI().getNavigator().navigateTo(MainView.class.getName());
				VaadinService.reinitializeSession(VaadinService.getCurrentRequest());
			} catch (Exception e) {
				log.info(e.getMessage());
				username.setValue("");
				username.setComponentError(new UserError("Неверное имя пользователя или пароль"));
				password.setValue("");
				password.setComponentError(new UserError("Неверное имя пользователя или пароль"));
			}
		}

	}

}
