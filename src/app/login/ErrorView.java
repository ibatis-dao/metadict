package app.login;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.vaadin.navigator.View;
import com.vaadin.navigator.ViewChangeListener.ViewChangeEvent;
import com.vaadin.ui.Label;
import com.vaadin.ui.VerticalLayout;

public class ErrorView extends VerticalLayout implements View {

	/**
	 * 
	 */
	private static final long serialVersionUID = 181184627697332783L;
	private static final transient Logger log = LoggerFactory.getLogger(ErrorView.class);

	public ErrorView() {
		log.trace(">> ErrorView()");
		//TODO сделать более человеческую страницу
		addComponent(new Label("403/404. Not authorized or Resource you tried to navigate to doesn't exist."));
	}
	
	@Override
	public void enter(ViewChangeEvent event) {
		log.trace(">> enter()");
	}

}
