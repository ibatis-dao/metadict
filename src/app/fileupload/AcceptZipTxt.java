package app.fileupload;

import com.vaadin.event.dd.DragAndDropEvent;
import com.vaadin.event.dd.acceptcriteria.AcceptCriterion;
import com.vaadin.event.dd.acceptcriteria.ClientSideCriterion;

public final class AcceptZipTxt extends ClientSideCriterion {

	private static final long serialVersionUID = 4500856330215674931L;
	private static AcceptCriterion singleton = new AcceptZipTxt();

    private AcceptZipTxt() {
    }

    public static AcceptCriterion get() {
        return singleton;
    }

    @Override
    public boolean accept(DragAndDropEvent dragEvent) {
    	return true;
    	/*
    	//log.trace(">> accept");
    	if (dragEvent != null) {
        	if (dragEvent.getTransferable() != null) {
        		for (String flavor : dragEvent.getTransferable().getDataFlavors()) {
        			log.debug("flavor="+flavor);
        		}
        		return true;
        	} else {
        		//log.debug("(dragEvent.getTransferable() == null)");
        	}
        } else {
        	//log.debug("(dragEvent == null)");
        }
        return false;
        */
    }
}