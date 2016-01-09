package app.login;

import java.io.Serializable;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.vaadin.server.Page;
import com.vaadin.server.VaadinSession;
import com.vaadin.server.WebBrowser;
import com.vaadin.ui.UI;

public class WebAppSession implements Serializable {

	private static final long serialVersionUID = -5001642299611070364L;
	private static final String sessCtx = "APP_SESSION_CTX";
	private static final transient Logger log = LoggerFactory.getLogger(WebAppSession.class);
	private WebBrowser webBrowser;
	
	public WebAppSession() {
		log.trace(">> constructor()");
		updateWebBrowser();
	}
	
	public static WebAppSession getCurrent(final boolean createNew){
		log.trace(">> getCurrent");
		WebAppSession aps = null;
		VaadinSession ses = VaadinSession.getCurrent();
		if (ses != null) {
			aps = (WebAppSession)ses.getAttribute(sessCtx);
			log.debug(sessCtx+"="+aps);
			if ((aps == null) && createNew) {
				aps = new WebAppSession();
			}
		} else {
			log.debug("ses == null");
		}
		return aps;
	}

	public WebBrowser getWebBrowser() {
		if (webBrowser == null) {
			updateWebBrowser();
		}
		log.debug("webBrowser="+webBrowser);
		return webBrowser;
	}

	@SuppressWarnings("deprecation")
	private void updateWebBrowser() {
		log.trace(">> updateWebBrowser");
		VaadinSession ses = VaadinSession.getCurrent();
		if (ses != null) {
			webBrowser = ses.getBrowser();
			if (webBrowser == null) {
				UI ui = UI.getCurrent();
				if (ui != null) {
					Page p = ui.getPage();
					if (p != null) {
						webBrowser = p.getWebBrowser();
					}
				}
			}
		}
		log.debug("webBrowser="+webBrowser);
	}
}
