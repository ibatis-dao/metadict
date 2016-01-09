package app;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.subject.Subject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.vaadin.navigator.View;
import com.vaadin.navigator.ViewChangeListener.ViewChangeEvent;
import com.vaadin.server.VaadinService;
import com.vaadin.ui.MenuBar;
import com.vaadin.ui.MenuBar.Command;
import com.vaadin.ui.MenuBar.MenuItem;
import com.vaadin.ui.Notification;
import com.vaadin.ui.Notification.Type;
import com.vaadin.ui.VerticalLayout;

import app.login.LoginView;

@SuppressWarnings("serial")
public class MainView extends VerticalLayout implements View {

	private static final transient Logger log = LoggerFactory.getLogger(MainView.class);
	private final MenuBar mainMenu;
	private final Command menuCommand;

	public MainView() {
		log.trace(">> MainView()");
        mainMenu = new MenuBar();
        mainMenu.setWidth(100.0f, Unit.PERCENTAGE);
        addComponent(mainMenu);

        menuCommand = new Command() {
	        @Override
	        public void menuSelected(final MenuItem selectedItem) {
	            Notification.show("Action " + selectedItem.getText(), Type.TRAY_NOTIFICATION);
	        }
	    };
	    
        @SuppressWarnings("unused")
		MenuItem childMenu;
        MenuItem fileMenu = mainMenu.addItem("Файл", null);
        //fileMenu.addSeparatorBefore(childMenu);
        childMenu = fileMenu.addItem("Выход", new Command() {
	        @Override
	        public void menuSelected(final MenuItem selectedItem) {
	        	Subject currentUser = SecurityUtils.getSubject();
	        	currentUser.logout();
	        	getUI().getNavigator().addView(LoginView.class.getName(), LoginView.class);
				getUI().getNavigator().navigateTo(LoginView.class.getName());
	        	VaadinService.reinitializeSession(VaadinService.getCurrentRequest());
	        }
	    });
        
        MenuItem cheaterMenu = mainMenu.addItem("Прочее", null);
        childMenu = cheaterMenu.addItem("Передача файла", new Command() {
	        @Override
	        public void menuSelected(final MenuItem selectedItem) {
	        	/*
	        	getUI().getNavigator().addView(SecureView.class.getName(), SecureView.class);
				getUI().getNavigator().navigateTo(SecureView.class.getName());
				*/
	        	getUI().getNavigator().addView(FileUploadView.class.getName(), FileUploadView.class);
				getUI().getNavigator().navigateTo(FileUploadView.class.getName());
	        }
	    });
        //childMenu.setEnabled(false);
        //childMenu.setIcon(icon);
        //childMenu = cheaterMenu.addItem("Террористы", menuCommand);
        //childMenu.setEnabled(false);
        //childMenu = cheaterMenu.addItem("Мошенники", menuCommand);
        //childMenu.setEnabled(false);
        childMenu = cheaterMenu.addItem("Проверка", menuCommand);
        //childMenu.setEnabled(false);
        //childMenu = cheaterMenu.addItem("Судебный запрет", menuCommand);
        //childMenu.setEnabled(false);
        
	}

	@Override
	public void enter(ViewChangeEvent event) {
		log.trace(">> enter()");
	}

}
