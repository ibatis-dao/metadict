package app.fileupload;

import java.io.File;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.vaadin.ui.Label;
import com.vaadin.ui.ProgressBar;

import app.util.Util;

public class FileHandleStatusUI extends FileHandleStatus {

	private static final long serialVersionUID = 8534195952302538055L;
	private static final transient Logger log = LoggerFactory.getLogger(FileHandleStatusUI.class);
	private Label fileNameUI;
	private Label fileMimeTypeUI;
	private Label fileSizeUI;
	private Label processNameUI;
	private Label bytesProcessedUI;
	private float percentProcessed;
	private ProgressBar percentProcessedUI;
	private File tempFile;
	
	public FileHandleStatusUI(
			String fileName, String fileMimeType, long fileSize,
			Label fileNameUI, Label fileMimeTypeUI, Label fileSizeUI
			) {
		this(fileName, fileMimeType, fileSize, null, 0.0f, 
			fileNameUI, fileMimeTypeUI, fileSizeUI, null, null);
	}

	public FileHandleStatusUI(
			String fileName, String fileMimeType, long fileSize, String processName, float percentProcessed,
			Label fileNameUI, Label fileMimeTypeUI, Label fileSizeUI, Label processNameUI, ProgressBar percentProcessedUI
			) {
		super(fileName, fileMimeType, fileSize);
		log.trace(">> constructor(fileName={}, fileMimeType={}, fileSize={}, processName={}", fileName, fileMimeType, fileSize, processName);
		this.fileNameUI = fileNameUI;
		this.fileMimeTypeUI = fileMimeTypeUI;
		this.fileSizeUI = fileSizeUI;
		this.processNameUI = processNameUI;
		this.percentProcessedUI = percentProcessedUI;
		setFileName(fileName);
		setFileMimeType(fileMimeType);
		setFileSize(fileSize);
		setProcessName(processName);
		setPercentProcessed(percentProcessed);
	}
	
	@Override
	public void setFileName(String fileName) {
		super.setFileName(fileName);
		if (fileNameUI != null) {
			fileNameUI.setCaption(fileName);
		}
	}
	
	@Override
	public void setFileMimeType(String fileMimeType) {
		super.setFileMimeType(fileMimeType);
		if (fileMimeTypeUI != null) {
			fileMimeTypeUI.setCaption(fileMimeType);
		}
	}
	
	@Override
	public void setFileSize(long fileSize) {
		super.setFileSize(fileSize);
		if (fileSizeUI != null) {
			fileSizeUI.setCaption(Util.readableFileSize1024(fileSize));
		}
		setPercentProcessed(calcPercentProcessed());
	}
	
	@Override
	public void setBytesProcessed(long bytesProcessed) {
		super.setBytesProcessed(bytesProcessed);
		if (bytesProcessedUI != null) {
			bytesProcessedUI.setCaption(Util.readableFileSize1024(bytesProcessed));
		}
		setPercentProcessed(calcPercentProcessed());
	}
	
	@Override
	public void setProcessName(String processName) {
		super.setProcessName(processName);
		if (processNameUI != null) {
			processNameUI.setCaption(processName);
		}
	}

	public float calcPercentProcessed() {
		if ((getFileSize() != 0) && (getFileSize() != -1)) {
			return (float)(getBytesProcessed()*1.0d)/getFileSize();
		} else {
			return percentProcessed;
		}
	}

	public void setPercentProcessed(float percentProcessed) {
		this.percentProcessed = percentProcessed;
		if (percentProcessedUI != null) {
			percentProcessedUI.setIndeterminate((getFileSize() <= 0));
			percentProcessedUI.setValue(percentProcessed);
		}
	}

	public File getTempFile() {
		return tempFile;
	}

	public void setTempFile(File tempFile) {
		this.tempFile = tempFile;
	}

}
