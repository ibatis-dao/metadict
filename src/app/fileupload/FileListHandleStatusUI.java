package app.fileupload;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.vaadin.ui.ComponentContainer;
import com.vaadin.ui.GridLayout;
import com.vaadin.ui.Html5File;
import com.vaadin.ui.Label;
import com.vaadin.ui.ProgressBar;

public class FileListHandleStatusUI {

	private static final transient Logger log = LoggerFactory.getLogger(FileListHandleStatusUI.class);
	private List<FileHandleStatusUI> fileStatusUI;
	private GridLayout lay;
	
	public FileListHandleStatusUI(final String fileNameTitle, final String fileMimeTypeTitle, final String fileSizeTitle,
			final String processNameTitle, final String percentProcessedTitle) {
		log.trace(">> constructor");
		fileStatusUI = new ArrayList<FileHandleStatusUI>();
    	lay = new GridLayout(5, 1);
    	lay.setSizeUndefined();
    	lay.setMargin(true);
    	lay.setSpacing(true);
    	lay.addComponent(new Label(fileNameTitle));
    	lay.addComponent(new Label(fileMimeTypeTitle));
    	lay.addComponent(new Label(fileSizeTitle));
    	lay.addComponent(new Label(processNameTitle));
    	lay.addComponent(new Label(percentProcessedTitle));
	}
	
	public void addRows(final Html5File[] files, final String processName) {
		if (files != null) {
			for (final Html5File html5File : files) {
				addRow(html5File.getFileName(), html5File.getType(), html5File.getFileSize(), processName);
			}
		}
	}

	public FileHandleStatusUI addRow(final String fileName, final String fileMimeType, final long fileSize, final String processName) {
		log.trace(">> addRow(fileName={}, fileMimeType={}, fileSize={}, processName={}", fileName, fileMimeType, fileSize, processName);
		Label fileNameUI = new Label();
    	Label fileMimeTypeUI = new Label();
    	Label fileSizeUI = new Label();
    	Label processNameUI = new Label();
    	ProgressBar percentProcessedUI = new ProgressBar(0.0f);
    	FileHandleStatusUI fhs = new FileHandleStatusUI(
    		fileName, fileMimeType, fileSize, processName, 0.0f, 
    		fileNameUI, fileMimeTypeUI, fileSizeUI, processNameUI, percentProcessedUI
    	);
    	fileStatusUI.add(fhs);
        lay.addComponent(fileNameUI);
        lay.addComponent(fileMimeTypeUI);
        lay.addComponent(fileSizeUI);
        lay.addComponent(processNameUI);
        percentProcessedUI.setIndeterminate(false);
        //percentProcessedUI.setCaption(fileName);
        lay.addComponent(percentProcessedUI);
        return fhs;
    }
    
    public ComponentContainer getUIContainer() {
    	return lay;
    }

}
