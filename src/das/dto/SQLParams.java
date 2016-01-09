/*
 * Copyright 2015 serg.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package das.dto;

import das.dao.filter.ISqlFilterable;
import das.dao.sort.IDAOSortOrder;

/**
 *
 * @author serg
 */
public class SQLParams {
    private int offset;
    private int pagelength;
    private IDAOSortOrder sortOrder;
    private ISqlFilterable filter;
    private Object example; // query by example

    public SQLParams(){
    	this(0, 0, null, null);
    }
    
    public SQLParams(int offset, int pagelength){
        this(offset, pagelength, null, null);
    }
    
    public SQLParams(int offset, int pagelength, IDAOSortOrder sortOrder){
        this(offset, pagelength, sortOrder, null);
    }
    
    public SQLParams(int offset, int pagelength, ISqlFilterable filter){
        this(offset, pagelength, null, filter);
    }
    
    public SQLParams(int offset, int pagelength, IDAOSortOrder sortOrder, ISqlFilterable filter){
    	this.offset = offset;
        this.pagelength = pagelength;
        this.sortOrder = sortOrder;
        this.filter = filter;
        this.example = null;
    }
    
    public int getOffset() {
		return offset;
	}

	public void setOffset(int offset) {
		this.offset = offset;
	}

	public int getPagelength() {
		return pagelength;
	}

	public void setPagelength(int pagelength) {
		this.pagelength = pagelength;
	}

	public IDAOSortOrder getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(IDAOSortOrder sortOrder) {
        this.sortOrder = sortOrder;
    }

    public ISqlFilterable getFilter() {
        return filter;
    }

    public void setFilter(ISqlFilterable filter) {
        this.filter = filter;
    }

    public Object getExample() {
        return example; // query by example
    }

    public void setExample(Object example) {
        this.example = example; // query by example
    }

}
