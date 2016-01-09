package app;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.vaadin.navigator.View;
import com.vaadin.navigator.ViewChangeListener.ViewChangeEvent;
import com.vaadin.server.StreamResource;
import com.vaadin.server.StreamResource.StreamSource;
import com.vaadin.server.WebBrowser;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.Alignment;
import com.vaadin.ui.Component;
import com.vaadin.ui.CssLayout;
import com.vaadin.ui.Embedded;
import com.vaadin.ui.Label;
import com.vaadin.ui.Notification;
import com.vaadin.ui.Panel;
import com.vaadin.ui.UI;
import com.vaadin.ui.VerticalLayout;
import com.vaadin.ui.Window;

import app.fileupload.FileHandleStatusUI;
import app.fileupload.FileUploadDropTarget;
import app.fileupload.FileUploadDropTarget.FileUploadResult;
import app.login.WebAppSession;
import das.excpt.EUnsupported;

@SuppressWarnings("serial")
public class FileUploadView extends VerticalLayout implements View, FileUploadResult {
	
	// http://demo.vaadin.com/sampler/#ui/drag-drop/drag-from-desktop
	// https://dev.vaadin.com/svn/demo/sampler/src/com/vaadin/demo/sampler/features/upload/UploadWithProgressMonitoringExample.java

	private static final transient Logger log = LoggerFactory.getLogger(FileUploadView.class);

	public FileUploadView() {
		log.trace(">> SanctionFileUploadView()");
		CssLayout dropPane = new CssLayout();
		log.trace("before new FileUploadDropTarget()");
		if (supportsHtml5FileDrop()) {
			dropPane.addComponent(new Label(
				"Для передачи файла на сервер<br/>перетащите сюда файл<br/>или укажите его здесь<br/>", 
				ContentMode.HTML));
		} else {
			dropPane.addComponent(new Label(
				"Для передачи файла на сервер<br/>нажмите эту кнопку для выбора файла<br/>", 
				ContentMode.HTML));
		}
        final FileUploadDropTarget dropBox = new FileUploadDropTarget(dropPane, this);
        dropPane.addStyleName("drop-area");
        dropBox.setSizeUndefined();
 
        Panel panel = new Panel(dropBox);
        panel.setSizeUndefined();
        panel.addStyleName("no-vertical-drag-hints");
        panel.addStyleName("no-horizontal-drag-hints");
        addComponent(panel);
		setComponentAlignment(panel, Alignment.MIDDLE_CENTER);
        setSizeFull();
        setSpacing(true);
		log.trace("<< SanctionFileUploadView()");
	}

	@Override
	public void enter(ViewChangeEvent event) {
		log.trace(">> enter()");
	}
	
    @Override
    public void attach() {
        super.attach();
        if (!supportsHtml5FileDrop()) {
        	Notification.show(
                "Перетаскивание файлов поддерживается в Firefox 3.6+, Chrome 6+, и Safari 5+. " +
                "Текст можно перетаскивать и в других браузерах.", 
                Notification.Type.WARNING_MESSAGE
            );
        }
    }
    
    private boolean supportsHtml5FileDrop() {
    	log.trace(">> supportsHtml5FileDrop");
    	boolean supportsHtml5FileDrop = false;
    	WebAppSession ap = WebAppSession.getCurrent(true);
    	if (ap != null) {
    		WebBrowser webBrowser = ap.getWebBrowser();
            // warn the user if the browser does not support file drop
            supportsHtml5FileDrop = webBrowser.isFirefox()
                && (webBrowser.getBrowserMajorVersion() >= 4 
                    || (webBrowser.getBrowserMajorVersion() == 3 
                    && 
                    webBrowser.getBrowserMinorVersion() >= 6));
            if (!supportsHtml5FileDrop) {
                // pretty much all chromes and safaris are new enough
                supportsHtml5FileDrop = webBrowser.isChrome()
                    || webBrowser.isSafari()
                    && webBrowser.getBrowserMajorVersion() > 4;
            }
    	}
        return supportsHtml5FileDrop;
    }

	// implements FileUploadDropTarget.FileUploadResult
    @Override
	public void OnSuccess(Object[] params) {
		if ((params != null) && (params.length == 1)) {
			FileHandleStatusUI fileStatusUI = (FileHandleStatusUI)params[0];
			if ("text/plain".equalsIgnoreCase(fileStatusUI.getFileMimeType())) {
	    		saveFile(fileStatusUI.getFileName(), fileStatusUI.getFileMimeType(), fileStatusUI.getTempFile());
	    	} else {
	    		showFile(fileStatusUI.getFileName(), fileStatusUI.getFileMimeType(), fileStatusUI.getTempFile());
	    	}
		} else {
			throw new IllegalArgumentException("params.length != 3");
		}
	}

    private void showFile(final String name, final String type, final File f) {
        // resource for serving the file contents
        final StreamSource streamSource = new StreamSource() {
            @Override
            public InputStream getStream() {
                if (f != null) {
                    try {
						return new FileInputStream(f);
					} catch (FileNotFoundException e) {
						log.error("Ошибка", e);
						return null;
					}
                }
                return null;
            }
        };
        final StreamResource resource = new StreamResource(streamSource, name);

        //TODO show the file contents - images only for now
        final Embedded embedded = new Embedded(name, resource);
        showComponent(embedded, name);
    }

    private void showComponent(final Component c, final String name) {
        final VerticalLayout layout = new VerticalLayout();
        layout.setSizeUndefined();
        layout.setMargin(true);
        final Window w = new Window(name, layout);
        w.addStyleName("dropdisplaywindow");
        w.setSizeUndefined();
        w.setResizable(false);
        c.setSizeUndefined();
        layout.addComponent(c);
        UI.getCurrent().addWindow(w);

    }
    
    private void saveFile(final String name, final String type, final File f) {
    	log.trace(">> saveFile");
    	if (f != null) {
            InputStream input;
			try {
				input = new FileInputStream(f);
	            log.debug("before saveStream");
	            try {
		            saveStream(input);
		            log.debug("after saveStream");
					Notification.show("Файл загружен", "Загрузка файла ["+name+" ("+type+")] прошла успешно", Notification.Type.HUMANIZED_MESSAGE);
	            } catch (IOException e) {
	    			log.error("Ошибка при обработке файла", e);
	    			Notification.show("Ошибка при обработке файла", e.getMessage(), Notification.Type.ERROR_MESSAGE);
	    		}
			} catch (FileNotFoundException e1) {
				log.error("Ошибка при обработке файла", e1);
    			Notification.show("Ошибка при обработке файла", e1.getMessage(), Notification.Type.ERROR_MESSAGE);
			}
        }
    }

	private BufferedReader parseFileHeaders(InputStream input) throws IOException {
    	BufferedReader br = new BufferedReader(new InputStreamReader(input));
    	String line;
    	String[] linesToSkip = new String[3]; // анализируем 3 строки с заголовками в начале файла
    	linesToSkip[0] = "|  |  |";
    	linesToSkip[1] = "";
    	linesToSkip[2] = "";
    	for (int i=0; i < linesToSkip.length; i++) {
    		line = br.readLine();
    		if (!linesToSkip[i].equals(line)) {
    			throw new EUnsupported("Неверный формат заголовков файла");
    		}
    	};
    	return br;
	}

    public void saveStream(InputStream input) throws IOException {
    	log.trace(">> saveStream");
		if (input == null) {
    		throw new IllegalArgumentException("input == null");
    	}
		Notification.show("Обработка файла", "Условно считаем, что файл загружен", 
			Notification.Type.ASSISTIVE_NOTIFICATION);
		/*
		BlackListDAO dao = new BlackListDAO();
		dao.clearAll();
		BufferedReader br = parseSanctionHeaders(input);
		BlackListConvertor blc = new BlackListConvertor();
    	String line;
    	int ln = 0;
    	BlackList bl;
    	List<BlackList> list = new ArrayList<BlackList>();
		try {
			line = br.readLine();
	    	while (line != null) {
	    		bl = blc.fromString(line);
	    		list.add(bl);
	    		if (ln % 10000 == 0) {
	    			dao.insert(list);
	    			list.clear();
	    		}
	    		ln++;
	            line = br.readLine();
	        }
	    	if (!list.isEmpty()) {
	    		dao.insert(list);
    			list.clear();
	    	}
	    	log.info(">> parsed & saved "+ln+" lines");
	    	br.close();
		} catch (IOException e) {
			log.error("Ошибка при сохранении из потока в БД", e);
			try {br.close();} catch (IOException e2) {}
			throw e;
		}
		*/
	}

}
