package app.fileupload;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.vaadin.event.dd.DragAndDropEvent;
import com.vaadin.event.dd.DropHandler;
import com.vaadin.event.dd.acceptcriteria.AcceptAll;
import com.vaadin.event.dd.acceptcriteria.AcceptCriterion;
import com.vaadin.server.StreamVariable;
import com.vaadin.ui.ComponentContainer;
import com.vaadin.ui.DragAndDropWrapper;
import com.vaadin.ui.Html5File;
import com.vaadin.ui.Notification;
import com.vaadin.ui.UI;
import com.vaadin.ui.Upload;
import com.vaadin.ui.Upload.FailedEvent;
import com.vaadin.ui.Upload.SucceededEvent;

import app.util.Util;

import com.vaadin.ui.Window;

public class FileUploadDropTarget extends DragAndDropWrapper implements DropHandler, 
	Upload.Receiver, Upload.ProgressListener, Upload.SucceededListener, Upload.FailedListener {

	private static final long serialVersionUID = 1515551322610160793L;
	private static final transient Logger log = LoggerFactory.getLogger(FileUploadDropTarget.class);
    private final long fileSizeLimit = 10737418240L; // 10GB
    private final FileUploadResult uploadResult;
    private Window pgsWnd;
    private int fileCnt;
    private FileListHandleStatusUI fileListStatusUI;
    FileHandleStatusUI fileStatusUI;
    
    public FileUploadDropTarget(final ComponentContainer root, final FileUploadResult uploadResult) {
        super(root);
        setDropHandler(this);
        fileListStatusUI = new FileListHandleStatusUI("Файл", "Тип", "Размер", "Процесс", "Состояние");
        pgsWnd = new Window("Прием и обработка файлов");
        pgsWnd.setVisible(false);
        pgsWnd.addStyleName("dropdisplaywindow");
        pgsWnd.setSizeUndefined();
        pgsWnd.setResizable(true);
        pgsWnd.setContent(fileListStatusUI.getUIContainer());
        UI.getCurrent().addWindow(pgsWnd);
        this.uploadResult = uploadResult;
        if (root != null) {
        	Upload upload = new Upload("Файл для передачи", this);
        	upload.setImmediate(true);
        	upload.addProgressListener(this);
        	upload.addSucceededListener(this);
        	upload.addFailedListener(this);
        	root.addComponent(upload);
        }
        
    }
    
    private synchronized int decFileCnt() {
    	fileCnt--;
    	if ((fileCnt <= 0) && (UI.getCurrent().getPollInterval() > 0)) {
    		UI.getCurrent().setPollInterval(-1); // остановка обновления ProgressBar
    	}
    	return fileCnt;
    }

    private synchronized int incFileCnt() {
    	fileCnt++;
    	if ((fileCnt > 0) && (UI.getCurrent().getPollInterval() <= 0)) {
    		UI.getCurrent().setPollInterval(5000); // для обновления ProgressBar
    	}
    	return fileCnt;
    }
    
    @SuppressWarnings("serial")
	@Override
    public void drop(final DragAndDropEvent dropEvent) {

        // expecting this to be an html5 drag
        final WrapperTransferable tr = (WrapperTransferable) dropEvent.getTransferable();
        final Html5File[] files = tr.getFiles();
        if (files != null) {
        	
            for (final Html5File html5File : files) {
                final String fileName = html5File.getFileName();
                
                if (html5File.getFileSize() > fileSizeLimit) {
                    Notification.show("Файл не принят. Размер файла ("+
                    	Util.readableFileSize1024(html5File.getFileSize())+
                    	") превышает максимально допустимый ("+
                    	Util.readableFileSize1024(fileSizeLimit)+")",
                    	Notification.Type.WARNING_MESSAGE);
                } else {
                    StreamVariable streamVariable = null;
                    pgsWnd.setVisible(true);
                    try {
						streamVariable = new StreamVariable() {

							File tempFile = File.createTempFile(fileName, ".tmp");
						    FileOutputStream fos = new FileOutputStream(tempFile);
							FileHandleStatusUI status = fileListStatusUI.addRow(fileName, html5File.getType(), html5File.getFileSize(), "Передача файла");
							
							@Override
						    public OutputStream getOutputStream() {
						        return fos;
						    }

						    @Override
						    public boolean listenProgress() {
						        return true;
						    }

						    @Override
						    public void onProgress(final StreamingProgressEvent event) {
						    	if (event != null) {
						    		status.setBytesProcessed(event.getBytesReceived());
						    		log.debug(">> onProgress(event.length="+event.getContentLength()+", event.received="+event.getBytesReceived()+")");
						    	} else {
						    		log.debug(">> onProgress(event==null)");
						        }
						    }

						    @Override
						    public void streamingStarted(final StreamingStartEvent event) {
						    	log.debug(">> streamingStarted");
						    	status.setTempFile(tempFile);
						    }

						    @Override
						    public void streamingFinished(final StreamingEndEvent event) {
						    	log.debug(">> streamingFinished");
						    	decFileCnt();
								if (uploadResult != null) {
									uploadResult.OnSuccess(new Object[]{status});
								} else {
									Notification.show("Обработка файла", "Обработка файла не определена", Notification.Type.ERROR_MESSAGE);
								}
						    }

						    @Override
						    public void streamingFailed(final StreamingErrorEvent event) {
						    	log.debug(">> streamingFailed");
						    	status.setProcessName("Ошибка при обработке файла:"+event.getException().getMessage());
						    	decFileCnt();
						    	if (tempFile.exists()) {
						    		tempFile.delete();
						    	}
						    	Notification.show("Ошибка при обработке файла", event.getException().getMessage(), Notification.Type.ERROR_MESSAGE);
						    }

						    @Override
						    public boolean isInterrupted() {
						        return false;
						    }
						};
					} catch (IOException e) {
						log.error("Ошибка при обработке файла", e);
		    			Notification.show("Ошибка при обработке файла", e.getMessage(), Notification.Type.ERROR_MESSAGE);
					}
					incFileCnt();
					html5File.setStreamVariable(streamVariable);
                }
            }

        } else {
            final String text = tr.getText();
            if (text != null) {
                showText(text);
            }
        }
    }

    private void showText(final String text) {
        Notification.show("Брошенный текст", text, Notification.Type.HUMANIZED_MESSAGE);
    }

    @Override
    public AcceptCriterion getAcceptCriterion() {
        return AcceptAll.get();
    	//return AcceptZipTxt.get(); // не работает. и не понятно, почему
    }
    
    public interface FileUploadResult {
    	void OnSuccess(Object[] params);
    }

    // implements Upload.Receiver
    @Override  
	public OutputStream receiveUpload(String filename, String mimeType) {
    	log.trace(">> receiveUpload");
    	FileOutputStream fos = null;
    	File tempFile = null;
		try {
			log.debug("filename="+filename);
			if ((filename == null) || (filename.isEmpty())) {
				throw new IllegalArgumentException("Не указано имя файла");
			}
			tempFile = File.createTempFile(filename, ".tmp");
		    fos = new FileOutputStream(tempFile);
		} catch (Exception e) {
			log.error("Ошибка при обработке файла", e);
			Notification.show("Ошибка при обработке файла", e.getMessage(), Notification.Type.ERROR_MESSAGE);
		}
		//создаем таблицу с описанием файла и индикатором загрузки
		fileStatusUI = fileListStatusUI.addRow(filename, mimeType, -1, "Передача файла");
		fileStatusUI.setTempFile(tempFile);
		pgsWnd.setVisible(true);
		incFileCnt();
		return fos;
	}

	// implements Upload.ProgressListener
    @Override
	public void updateProgress(long readBytes, long contentLength) {
    	log.trace(">> updateProgress");
		fileStatusUI.setFileSize(contentLength);
		fileStatusUI.setBytesProcessed(readBytes);
    	if (contentLength > 0) {
    		log.debug("contentLength="+contentLength+", readBytes="+readBytes);
    	} else {
    		log.debug("contentLength <= 0");
        }
	}

	// implements Upload.SucceededListener
	@Override
	public void uploadSucceeded(SucceededEvent event) {
    	log.debug(">> streamingFinished");
    	decFileCnt();
		if (event != null) {
			if (fileStatusUI.isSameFile(event.getFilename(), event.getMIMEType())) {
				if (uploadResult != null) {
					fileStatusUI.setFileSize(event.getLength());
					uploadResult.OnSuccess(new Object[]{fileStatusUI});
				}  else {
					Notification.show("Обработка файла", "Обработка файла не определена", Notification.Type.ERROR_MESSAGE);
				}
			} else {
				throw new IllegalAccessError("event.getFilename() != fileStatusUI.getFileName()");
			}
		}
	}

	// implements Upload.FailedListener
	@Override
	public void uploadFailed(FailedEvent event) {
    	log.debug(">> streamingFailed");
    	decFileCnt();
    	if (event != null) {
    		if (fileStatusUI.isSameFile(event.getFilename(), event.getMIMEType(), event.getLength())) {
    			if ((fileStatusUI.getTempFile() != null) && (fileStatusUI.getTempFile().exists())) {
    				fileStatusUI.getTempFile().delete();
    			}
			} else {
				throw new IllegalAccessError("event.getFilename() != fileStatusUI.getFileName()");
			}
    	}
    	
    	Notification.show("Ошибка при обработке файла", event.getReason().getMessage(), Notification.Type.ERROR_MESSAGE);
	}
	
}
