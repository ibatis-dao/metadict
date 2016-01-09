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
package das.dao.sort;

/**
 * список сортировки в объектах доступа к данным
 * @author serg
 */
public interface ISortOrder {
    
    public enum Direction {
        ASC, DESC, NONE
    }
    
    /* возвращает имя поля с направлением сортировки */
    String build();
    int size();
    boolean isSortable(int index);
    String getName(int index);
    ISortOrder.Direction getDirection(int index);
    void add(String columnName, ISortOrder.Direction direction);
    void toggle(int index);
    boolean del(int index);
    void clear();
}
