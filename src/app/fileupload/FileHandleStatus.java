package app.fileupload;

import java.io.Serializable;
import java.util.Collection;
import java.util.HashSet;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FileHandleStatus implements Serializable {
	
	private static final long serialVersionUID = -2409630470988870604L;
	private static final transient Logger log = LoggerFactory.getLogger(FileHandleStatus.class);
	private String fileName;
	private String fileMimeType;
	private long fileSize;
	private String processName;
	private long bytesProcessed;
	private Collection<FileHandleStatus.EventListener> listeners; 

	public enum EventSource {
		Unknown, FileName, FileMimeType, FileSize, BytesProcessed, ProcessName, 
		onSuccess, onFail
	}
	
	public interface EventListener {
		void onChange(FileHandleStatus.EventSource source, FileHandleStatus current);
	}

	public FileHandleStatus(final String fileName, final String fileMimeType, final long fileSize) {
		this.fileName = fileName;
		log.trace(">> constructor(fileName={}, fileMimeType={}, fileSize={}", fileName, fileMimeType, fileSize);
		this.fileMimeType = fileMimeType;
		this.fileSize = fileSize;
		this.listeners = new HashSet<EventListener>();
	}
	
	public boolean addListener(FileHandleStatus.EventListener listener) {
		return listeners.add(listener);
	}

	public boolean removeListener(FileHandleStatus.EventListener listener) {
		return listeners.remove(listener);
	}
	
	private void tellToListeners(EventSource source) {
		for (FileHandleStatus.EventListener listener : listeners) {
			listener.onChange(source, this);
		}
	}

	public void onSuccess() {
		tellToListeners(EventSource.onSuccess);
	}
	
	public void onFail() {
		tellToListeners(EventSource.onFail);
	}
	
	private boolean sameStringIgnoreCase(final String one, final String two) {
		return (one != null) ? one.equalsIgnoreCase(two) : (two != null) ? two.equalsIgnoreCase(one) : false;
	}
	
	public boolean isSameFile(FileHandleStatus other) {
		if (other != null) {
			return sameStringIgnoreCase(fileName, other.fileName)
				&& sameStringIgnoreCase(fileMimeType, other.fileMimeType)
				&& (fileSize == other.fileSize);
		}
		return false;
	}

	public boolean isSameFile(final String fileName, final String fileMimeType) {
		log.trace(">> isSameFile(fileName={}, this.fileName={}, fileMimeType={}, this.fileMimeType={}", 
			fileName, this.fileName, fileMimeType, this.fileMimeType);
		return sameStringIgnoreCase(fileName, this.fileName)
			&& sameStringIgnoreCase(fileMimeType, this.fileMimeType);
	}

	public boolean isSameFile(final String fileName, final String fileMimeType, final long fileSize) {
		log.trace(">> isSameFile(fileName={}, this.fileName={}, fileMimeType={}, this.fileMimeType={}, fileSize={}, this.fileSize={}", 
			fileName, this.fileName, fileMimeType, this.fileMimeType, fileSize, this.fileSize);
		return sameStringIgnoreCase(fileName, this.fileName)
			&& sameStringIgnoreCase(fileMimeType, this.fileMimeType)
			&& (fileSize == this.fileSize);
	}

	/**
	 * @return the fileName
	 */
	public String getFileName() {
		return fileName;
	}

	/**
	 * @param fileName the fileName to set
	 */
	public void setFileName(String fileName) {
		if (
				((this.fileName != null) && (!this.fileName.equals(fileName))) 
				||
				((fileName != null) && (!fileName.equals(this.fileName)))
			) {
			this.fileName = fileName;
			tellToListeners(EventSource.FileName);
		}
	}

	/**
	 * @return the fileMimeType
	 */
	public String getFileMimeType() {
		return fileMimeType;
	}

	/**
	 * @param fileMimeType the fileMimeType to set
	 */
	public void setFileMimeType(String fileMimeType) {
		if (
				((this.fileMimeType != null) && (!this.fileMimeType.equals(fileMimeType))) 
				||
				((fileMimeType != null) && (!fileMimeType.equals(this.fileMimeType)))
			) {
			this.fileMimeType = fileMimeType;
			tellToListeners(EventSource.FileMimeType);
		}
	}

	/**
	 * @return the fileSize
	 */
	public long getFileSize() {
		return fileSize;
	}

	/**
	 * @param fileSize the fileSize to set
	 */
	public void setFileSize(long fileSize) {
		if (this.fileSize != fileSize) { 
			this.fileSize = fileSize;
			tellToListeners(EventSource.FileSize);
		}
	}

	/**
	 * @return the bytesProcessed
	 */
	public long getBytesProcessed() {
		return bytesProcessed;
	}

	/**
	 * @param bytesProcessed the bytesProcessed to set
	 */
	public void setBytesProcessed(long bytesProcessed) {
		if (this.bytesProcessed != bytesProcessed) { 
			this.bytesProcessed = bytesProcessed;
			tellToListeners(EventSource.BytesProcessed);
		}
	}

	public String getProcessName() {
		return processName;
	}

	public void setProcessName(String processName) {
		if (
				((this.processName != null) && (!this.processName.equals(processName))) 
				||
				((processName != null) && (!processName.equals(this.processName)))
			) {
			this.processName = processName;
			tellToListeners(EventSource.ProcessName);
		}
	}
	
}
