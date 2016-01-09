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

import das.excpt.EArgumentBreaksRule;
import das.excpt.ENegativeArgument;
import das.excpt.ENullArgument;
import java.util.Objects;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author serg
 */
public class NestedLongRange implements INestedRange<Long> {
    
    private static final Logger log = LoggerFactory.getLogger(NestedLongRange.class);
    private static final String entering = ">>> ";
    private static final String contructorMthdName = "contructor";
    private static final String setFirstMthdName = "setFirst";
    private static final String setLengthMthdName = "setLength";
    private static final String incLengthMthdName = "incLength";
    private static final String setLeftLimitMthdName = "setLeftLimit";
    private static final String equalsMthdName = "equals";
    private static final String IsInboundMthdName = "IsInbound";
    private static final String getMinDistanceMthdName = "getMinDistance";
    private static final String getMaxDistanceMthdName = "getMaxDistance";
    private static final String IsOverlappedMthdName = "IsOverlapped";
    private static final String OverlapMthdName = "Overlap";
    private static final String AddMthdName = "Add";
    private static final String ExtendMthdName = "Extend";
    private static final String ShiftMthdName = "Shift";
    private static final String ComplementMthdName = "Complement";

    private Long first;
    private Long length;
    private INestedRange<Long> parentRange;
    private static final INestedRange<Long> Singular = new SingularLongRange();
    
    public NestedLongRange() {
        
    }

    public NestedLongRange(INestedRange<Long> range) {
        this();
        if (range != null) {
            init(range.getFirst(), range.getLength(), range.getParentRange());
        }
    }

    public NestedLongRange(Long first, Long length, INestedRange<Long> parentRange) {
        init(first, length, null);
        log.trace(entering+contructorMthdName+"(first="+first+", length="+length+", parentRange="+parentRange+")");
        this.parentRange = parentRange;
    }
    /*
    private void init(Long first, Long length) {
        init(first, length, null);
    }
    */
    private void init(Long first, Long length, INestedRange<Long> parentRange) {
        this.first = first;
        this.length = length;
        this.parentRange = parentRange;
        IsInternalRulesOk("init(first, length, parentRange)");
    }
    
    private static boolean IsIntRule1Ok(final String callerMethodName, INestedRange<Long> parentRange, Long first) throws EArgumentBreaksRule {
        if (parentRange != null) {
            if (first.compareTo(parentRange.getFirst()) < 0) {
                throw new EArgumentBreaksRule(callerMethodName, "parentRange.first <= first");
            }
        }
        return true;
    }

    private static boolean IsIntRule2Ok(final String callerMethodName, Long length) throws ENegativeArgument {
        if (length < 0) {
            throw new ENegativeArgument(callerMethodName);
        }
        return true;
    }

    private static boolean IsIntRule3Ok(final String callerMethodName, Long first, Long length, INestedRange<Long> parentRange) throws EArgumentBreaksRule {
        if (parentRange != null) {
            if (parentRange.compareXandY(first+length-1L, parentRange.getLast()) > 0) {
                throw new EArgumentBreaksRule(callerMethodName, "first+length-1 <= parentRange.last");
            }
        }
        return true;
    }

    private static boolean IsIntRule4Ok(final String callerMethodName, INestedRange<Long> parentRange, INestedRange<Long> aRange) throws EArgumentBreaksRule {
        if ((parentRange != null) && (aRange != null)) {
            if (! aRange.IsInbound(parentRange)) {
                throw new EArgumentBreaksRule(callerMethodName, "parentRange.first >= aRange >= parentRange.last");
            }
        }
        return true;
    }
    
    private static boolean IsIntRule5Ok(final String callerMethodName, INestedRange<Long> parentRange, Long to) throws EArgumentBreaksRule {
        if (parentRange != null) {
            if ((to.compareTo(parentRange.getFirst()) < 0) || (to.compareTo(parentRange.getLast()) > 0)) {
                throw new EArgumentBreaksRule(callerMethodName, "parentRange.first >= to >= parentRange.last");
            }
        }
        return true;
    }
    
    private boolean IsInternalRulesOk(final String callerMethodName) {
        IsIntRule1Ok(callerMethodName, parentRange, first); // leftLimit <= first
        IsIntRule2Ok(callerMethodName, length); // length >= 0
        IsIntRule3Ok(callerMethodName, first, length, parentRange); // first+length-1 <= rightLimit
        IsIntRule4Ok(callerMethodName, parentRange, this); //parentRange.first >= aRange >= parentRange.last
        return true;
    }

    /**
     * @return the first
     */
    @Override
    public Long getFirst() {
        return first;
    }

    /**
     * @param first the first to set
     */
    @Override
    public void setFirst(Long first) {
        log.debug(entering+setFirstMthdName+"("+first+"). old first="+this.first);
        IsIntRule1Ok(setFirstMthdName, parentRange, first); // leftLimit <= first
        IsIntRule3Ok(setFirstMthdName, first, length, parentRange); // first+length-1 <= rightLimit
        this.first = first;
    }

    /**
     * @return the length
     */
    @Override
    public Long getLength() {
        return length;
    }

    /**
     * @param length the length to set
     */
    @Override
    public void setLength(Long length) {
        log.debug(entering+setLengthMthdName+"("+length+"). old length="+this.length);
        IsIntRule2Ok(setLengthMthdName, length); // length >= 0
        IsIntRule3Ok(setLengthMthdName, first, length, parentRange); // first+length-1 <= rightLimit
        this.length = length;
    }
    
    @Override
    public void incLength(Long increment) {
        log.debug(entering+incLengthMthdName+"("+increment+"). old length="+length);
        if (IsIntRule2Ok(incLengthMthdName, length+increment)) { // length >= 0
            IsIntRule3Ok(incLengthMthdName, first, length+increment, parentRange); // first+length-1 <= rightLimit
        }
        this.length = length + increment;
    }
    
    @Override
    public INestedRange<Long> getParentRange() {
        return parentRange;
    }
    
    private static NestedLongRange castItf(INestedRange<?> itf) {
        if (itf != null) {
            if (itf.getClass().isAssignableFrom(NestedLongRange.class)) {
                return (NestedLongRange)itf;
            } else {
                throw new ClassCastException();
            }
        } else {
            return null;
        }
    }

    @Override
    public void setParentRange(INestedRange<Long> parentRange) {
        //NestedLongRange p = castItf(parentRange);
        IsIntRule1Ok(setLeftLimitMthdName, parentRange, first); // leftLimit <= first
        IsIntRule3Ok(setLeftLimitMthdName, first, length, parentRange); // first+length-1 <= rightLimit
        this.parentRange = parentRange;
    }

    /**
     * @return the length
     */
    @Override
    public Long getLast() {
        return first+length-1;
    }
        
    @Override
    public NestedLongRange clone() {
        return new NestedLongRange(first, length, parentRange);
        /*
        try {
            NestedLongRange n = (NestedLongRange) super.clone();
            n.init(first, length, leftLimit, rightLimit);
            return n;
        } catch (CloneNotSupportedException ex) {
            log.error(null, ex);
            return new NestedLongRange(first, length, leftLimit, rightLimit);
        }
        */
    }
    
    /**
     * Определяет, равны ли (полностью совпадают) указанный диапазон с текущим
     * @param o
     * @return 
     */
    @Override
    public boolean equals(Object o) {
        if (o == null) {
        //если параметр = null, то он не может быть равен текущему экземпляру
            return false;
        } else {
            //если тип входного параметра нельзя присвоить текущему типу, 
            //то их нельзя сравнить. он не может быть равен текущему экземпляру
            if (! o.getClass().isAssignableFrom(this.getClass())) {
                log.debug(equalsMthdName+"("+o.getClass().getName()+")=FALSE");
                return false;
            } else {
                NestedLongRange r = (NestedLongRange)o;
                return (Objects.equals(parentRange, r.getParentRange()) && Objects.equals(first, r.getFirst()) && Objects.equals(length, r.getLength()));
                //return (hashCode() == o.hashCode());
            }
        }
    }

    @Override
    public int hashCode() {
        Long hash = 5l;
        hash = 89 * hash + first;
        hash = 89 * hash + length;
        if (parentRange != null) {
            hash = 89 * hash + parentRange.getFirst();
            hash = 89 * hash + parentRange.getLast();
        } else {
            hash = 89 * hash;
        }
        return hash.intValue();
    }
    
    @Override
    public String toString() {
        return "first="+first+", length="+length+", parentRange="+parentRange;
    }
    
    /**
     * Определяет, является ли текущий диапазон вырожденным
     * @return 
     */
    @Override
    public boolean IsSingular() {
        return ((this == Singular) || ((first == 0) && (length == 0) /*&& (parentRange == null)*/ ));
    }
    
    /**
     * Определяет, входит ли указанная отметка в текущий диапазон
     * @param value
     * @return 
     */
    @Override
    public boolean IsInbound(Long value) {
        log.trace(IsInboundMthdName+"(value="+value+"). first="+first+", last="+getLast());
        return (first <= value) && (value <= getLast());
    }
    
    /**
     * Определяет, накрывает ли целиком указанный диапазон (т.е. помещается ли 
     * текущий диапазон целиком внутри указанного)
     * @param aRange
     * @return 
     */
    @Override
    public boolean IsInbound(INestedRange<Long> aRange) {
        if (aRange == null) {
            throw new ENullArgument(IsInboundMthdName);
        } 
        return ((first.compareTo(aRange.getFirst()) >= 0) && (aRange.compareXandY(getLast(), aRange.getLast()) <= 0));
    }
    
    /*
    Определяет расстояние от указанной точки до до ближайшей границы диапазона
    Если точка указана за макс. границами, то ошибка
    Если точка внутри самого диапазона, то расстояние = 0
    */
    @Override
    public Long getMinDistance(Long to) {
        log.trace(getMinDistanceMthdName+"(to="+to+")");
        IsIntRule5Ok(getMinDistanceMthdName, parentRange, to); // leftLimit >= to >= rightLimit
        if (IsInbound(to)) {
            return 0L;
        } else {
            Long dist = Math.min(Math.abs(to - first), Math.abs(to - getLast()));
            log.debug("dist="+dist);
            if (to < first) {
                return - dist;
            } else {
                return dist;
            }
        }
    }
    
    /*
    Определяет расстояние от указанной точки до до ближайшей границы диапазона
    Если точка указана за макс. границами, то ошибка
    Если точка внутри самого диапазона, то расстояние = 0
    */
    @Override
    public Long getMaxDistance(Long to) {
        log.trace(getMaxDistanceMthdName+"(to="+to+")");
        IsIntRule5Ok(getMaxDistanceMthdName, parentRange, to); // leftLimit >= to >= rightLimit
        if (IsInbound(to)) {
            return 0L;
        } else {
            Long dist = Math.max(Math.abs(to - first), Math.abs(to - getLast()));
            log.debug("dist="+dist);
            if (to < first) {
                return - dist;
            } else {
                return dist;
            }
        }
    }
    
    /**
     * Определяет, пересекаются ли указанный диапазон с текущим
     * @param aRange
     * @return 
     */
    @Override
    public boolean IsOverlapped(INestedRange<Long> aRange) {
        if (aRange == null) {
            throw new ENullArgument(IsOverlappedMthdName);
        } 
        return !((getLast() < aRange.getFirst()) || (getFirst() > aRange.getLast()));
    }
    
    /**
     * Определяет область пересечения указанного диапазона с текущим
     * @param aRange
     * @return 
   */
    @Override
    public INestedRange<Long> Overlap(INestedRange<Long> aRange) {
        log.trace(OverlapMthdName+"(aRange)");
        if (aRange == null) {
            throw new ENullArgument(OverlapMthdName);
        }
        if (IsOverlapped(aRange)) {
            log.debug("is overlapped");
            Long maxStart = Math.max(first, aRange.getFirst());
            Long minLast = Math.min(getLast(), aRange.getLast());
            return new NestedLongRange(maxStart, minLast - maxStart + 1, parentRange);
        } else {
            log.debug("Is not overlapped. returns Singular");
            return Singular;
        }
    }
    
    /**
     * Добавляет указанный диапазон к текущему. 
     * Результирующий диапазон включает в себя оба диапазона и промежуток между ними (если он был).
     * @param aRange
     * @return 
     */
    @Override
    public INestedRange<Long> Add(INestedRange<Long> aRange) {
        if (aRange == null) {
            throw new ENullArgument(AddMthdName);
        }
        NestedLongRange r = castItf(aRange);
        IsIntRule4Ok(AddMthdName, parentRange, r); //parentRange.first >= aRange >= parentRange.last
        Long minStart = Math.min(first, r.getFirst());
        Long maxLast = Math.max(getLast(), r.getLast());
        log.debug(AddMthdName+"(). minStart="+minStart+", maxLast="+maxLast);
        return new NestedLongRange(minStart, maxLast - minStart + 1, parentRange);
    }

    /**
     * Продлевает текущий диапазон до указанной точки. 
     * @param to
     * @return 
     */
    @Override
    public INestedRange<Long> Extend(Long to) {
        IsIntRule5Ok(ExtendMthdName, parentRange, to); // leftLimit >= to >= rightLimit
        if (IsInbound(to)) {
            return Singular;
        } else {
            IsIntRule5Ok(ExtendMthdName, parentRange, to); // leftLimit >= to >= rightLimit
            Long minStart = Math.min(first, to);
            Long maxLast = Math.max(getLast(), to);
            log.debug(ExtendMthdName+"(). minStart="+minStart+", maxLast="+maxLast);
            return new NestedLongRange(minStart, maxLast - minStart + 1, parentRange);
        }
    }

    /*
    * смещает начало диапазона на указанную величину
    */
    @Override
    public INestedRange<Long> Shift(Long value) {
        //setFirst(first+value);
        IsIntRule5Ok(ShiftMthdName, parentRange, first+value); // leftLimit >= first+value >= rightLimit
        return new NestedLongRange(first+value, length, parentRange);
    }
    
    /**
     * Возвращает диапазон, который дополняет текущий диапазон до указанной точки. 
     * @param to
     * @return 
     */
    @Override
    public INestedRange<Long> Complement(Long to) {
        log.trace(ComplementMthdName+"(to="+to+")");
        Long dist = getMinDistance(to);
        if (dist < 0) {
            return new NestedLongRange(first + dist, - dist, parentRange);
        } else {
            if (dist > 0) {
                return new NestedLongRange(first + length, dist, parentRange);
            } else {
                return Singular;
            }
        }
    }

    @Override
    public Long NumberAdd(Number x, Number y) {
        return x.longValue() + y.longValue();
    }

    @Override
    public Long NumberSub(Number x, Number y) {
        return x.longValue() - y.longValue();
    }
    
    @Override
    public int compareXandY(Number x, Number y) {
        Long xlng = x.longValue();
        return xlng.compareTo(y.longValue());
    }

    @Override
    public Long valueOf(Number v) {
        return v.longValue();
    }

    /*
    @Override
    public INestedRange<Long> Complement(INestedRange<Long> aRange) {
        log.trace(ComplementMthdName+"(aRange="+aRange+")");
        if (IsInbound(aRange)) {
            //если текущий диапазон помещается целиком внутри указанного
            //то все плохо
            if (equals(aRange)) {
                return clone();
            }
            getMaxDistance(aRange);
        }
        Long dist = getMinDistance(aRange);
        if (dist < 0) {
            return new NestedLongRange(first + dist, - dist, parentRange);
        } else {
            if (dist > 0) {
                return new NestedLongRange(first + length, dist, parentRange);
            } else {
                return Singular;
            }
        }
    }
    */
    /*
    * минимальное расстояние от границ текущего диапазона до указанного
    */
    /*
    @Override
    public Long getMinDistance(NestedLongRange aRange) {
        Long minLen = Math.min(Math.abs(first - aRange.getFirst()), Math.abs(first - aRange.getLast()));
        minLen = Math.min(minLen, Math.min(Math.abs(getLast() - aRange.getFirst()), Math.abs(getLast() - aRange.getLast())));
        log.debug("getMinDistance(). minLen="+minLen);
        return minLen;
    }
    */
    /*
    * максимальное расстояние от границ текущего диапазона до указанного
    */
    /*
    @Override
    public Long getMaxDistance(NestedLongRange aRange) {
        Long maxLen = Math.max(Math.abs(first - aRange.getFirst()), Math.abs(first - aRange.getLast()));
        maxLen = Math.max(maxLen, Math.max(Math.abs(getLast() - aRange.getFirst()), Math.abs(getLast() - aRange.getLast())));
        log.debug("getMaxDistance(). maxLen="+maxLen);
        return maxLen;
    }
    */
    public static class SingularLongRange implements INestedRange<Long> {

        private static final String ns = "Singular range does not support any operation on it.";

        SingularLongRange() {
        }
        
        @Override
        public Long getFirst() {
            return 0L;
        }

        @Override
        public void setFirst(Long first) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public Long getLength() {
            return 0L;
        }

        @Override
        public void setLength(Long length) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public void incLength(Long increment) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public INestedRange<Long> getParentRange() {
            return null;
        }

        @Override
        public void setParentRange(INestedRange<Long> parentRange) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public Long getLast() {
            return 0L;
        }

        @Override
        public boolean IsSingular() {
            return true;
        }

        @Override
        public boolean IsInbound(Long value) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public boolean IsInbound(INestedRange<Long> aRange) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public Long getMinDistance(Long to) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public Long getMaxDistance(Long to) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public boolean IsOverlapped(INestedRange<Long> aRange) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public INestedRange<Long> Overlap(INestedRange<Long> aRange) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public INestedRange<Long> Add(INestedRange<Long> aRange) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public INestedRange<Long> Extend(Long to) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public INestedRange<Long> Shift(Long value) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public INestedRange<Long> Complement(Long to) {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public INestedRange<Long> clone() {
            throw new UnsupportedOperationException(ns);
        }

        @Override
        public Long valueOf(Number v) {
            return v.longValue();
        }

        @Override
        public Long NumberAdd(Number x, Number y) {
            return x.longValue() + y.longValue();
        }

        @Override
        public Long NumberSub(Number x, Number y) {
            return x.longValue() - y.longValue();
        }

        @Override
        public int compareXandY(Number x, Number y) {
            Long xlng = x.longValue();
            return xlng.compareTo(y.longValue());
        }

}
}
