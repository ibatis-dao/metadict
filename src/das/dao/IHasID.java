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
package das.dao;

import java.io.Serializable;

/**
 * based on org.datafx.util.EntityWithId
 * 
 * A base interface for all entities that have a unique id
 * @param <T> type of the id
 * @author serg
 */
public interface IHasID<T> extends Serializable {
//TODO нужен ли этот интерфейс ?
    /**
     * Returns the id
     * @return the id
     */
    T getId();
}
