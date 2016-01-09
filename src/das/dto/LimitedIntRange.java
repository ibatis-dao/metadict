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
import das.excpt.EUnsupported;
import java.util.Objects;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author serg
 */
public class LimitedIntRange {
    
    private static final Logger log = LoggerFactory.getLogger(LimitedIntRange.class);
    private static final String entering = ">>> ";
    private static final String contructorMthdName = "contructor";
    private static final String setFirstMthdName = "setFirst";
    private static final String setLengthMthdName = "setLength";
    private static final String incLengthMthdName = "incLength";
    private static final String setLeftLimitMthdName = "setLeftLimit";
    private static final String setRightLimitMthdName = "setRightLimit";
    private static final String equalsMthdName = "equals";
    private static final String IsInboundMthdName = "IsInbound";
    private static final String getMinDistanceMthdName = "getMinDistance";
    private static final String getMaxDistanceMthdName = "getMaxDistance";
    private static final String IsOverlappedMthdName = "IsOverlapped";
    private static final String OverlapMthdName = "Overlap";
    private static final String AddMthdName = "Add";
    private static final String ExtendMthdName = "Extend";
    private static final String ComplementMthdName = "Complement";
    
    private int first;
    private int length;
    private int leftLimit;
    private int rightLimit;
    private static final LimitedIntRange Singular = new LimitedIntRange(0, 0, 0, 0);

    /*
    public LimitedIntRange() {
        first = 0;
        length = 0;
        leftLimit = 0;
        rightLimit = Integer.MAX_VALUE;
    }

    public LimitedIntRange(int first, int length) {
        log.trace(entering+contructorMthdName+"(first="+first+", length="+length+")");
        init(first, length);
    }
    */
    public LimitedIntRange(int first, int length, int leftLimit, int rightLimit) {
        init(first, length, leftLimit, rightLimit);
        log.trace(entering+contructorMthdName+"(first="+first+", length="+length+", leftLimit="+leftLimit+", rightLimit="+rightLimit+")");
        this.leftLimit = leftLimit;
        this.rightLimit = rightLimit;
    }
    /*
    private void init(int first, int length) {
        init(first, length, 0, Integer.MAX_VALUE);
    }
    */
    private void init(int first, int length, int leftLimit, int rightLimit) {
        this.first = first;
        this.length = length;
        this.leftLimit = leftLimit;
        this.rightLimit = rightLimit;
        IsInternalRulesOk("init(first, length, leftLimit, rightLimit)");
    }
    
    private static boolean IsIntRule1Ok(final String callerMethodName, int leftLimit, int first) throws EArgumentBreaksRule {
        if (first < leftLimit) {
            throw new EArgumentBreaksRule(callerMethodName, "leftLimit <= first");
        }
        return true;
    }

    private static boolean IsIntRule2Ok(final String callerMethodName, int length) throws ENegativeArgument {
        if (length < 0) {
            throw new ENegativeArgument(callerMethodName);
        }
        return true;
    }

    private static boolean IsIntRule3Ok(final String callerMethodName, int first, int length, int rightLimit) throws EArgumentBreaksRule {
        if (first+length-1 > rightLimit) {
            throw new EArgumentBreaksRule(callerMethodName, "first+length-1 <= rightLimit");
        }
        return true;
    }

    private static boolean IsIntRule4Ok(final String callerMethodName, int leftLimit, int rightLimit) throws EArgumentBreaksRule {
        if (leftLimit > rightLimit) {
            throw new EArgumentBreaksRule(callerMethodName, "leftLimit <= rightLimit");
        }
        return true;
    }

    private static boolean IsIntRule5Ok(final String callerMethodName, int leftLimit, int to, int rightLimit) throws EArgumentBreaksRule {
        if ((to < leftLimit) || (to > rightLimit)) {
            throw new EArgumentBreaksRule(callerMethodName, "leftLimit >= to >= rightLimit");
        }
        return true;
    }
    
    private static boolean IsIntRule6Ok(LimitedIntRange instance, final String callerMethodName, int first, int length, int leftLimit, int rightLimit) throws EArgumentBreaksRule {
        if (instance == Singular) {
            if ((first != 0) || (length != 0) || (leftLimit != 0) || (rightLimit != 0)) {
                throw new EArgumentBreaksRule(callerMethodName, "Singular range can not have non zero params");
            }
        }
        return true;
    }
    
    private boolean IsInternalRulesOk(final String callerMethodName) {
        IsIntRule1Ok(callerMethodName, leftLimit, first); // leftLimit <= first
        IsIntRule2Ok(callerMethodName, length); // length >= 0
        IsIntRule3Ok(callerMethodName, first, length, rightLimit); // first+length-1 <= rightLimit
        IsIntRule4Ok(callerMethodName, leftLimit, rightLimit); // leftLimit <= rightLimit
        IsIntRule6Ok(this, callerMethodName, first, length, leftLimit, rightLimit); //check Singular for non-zeros
        return true;
    }
    /**
     * @return the first
     */
    public int getFirst() {
        return first;
    }

    /**
     * @param first the first to set
     */
    public void setFirst(int first) {
        log.debug(entering+setFirstMthdName+"("+first+"). old value="+this.first);
        IsIntRule1Ok(setFirstMthdName, leftLimit, first); // leftLimit <= first
        IsIntRule3Ok(setFirstMthdName, first, length, rightLimit); // first+length-1 <= rightLimit
        IsIntRule6Ok(this, setFirstMthdName, first, length, leftLimit, rightLimit); //check Singular for non-zeros
        this.first = first;
    }

    /**
     * @return the length
     */
    public int getLength() {
        return length;
    }

    /**
     * @param length the length to set
     */
    public void setLength(int length) {
        log.debug(entering+setLengthMthdName+"("+length+")");
        IsIntRule2Ok(setLengthMthdName, length); // length >= 0
        IsIntRule3Ok(setLengthMthdName, first, length, rightLimit); // first+length-1 <= rightLimit
        IsIntRule6Ok(this, setLengthMthdName, first, length, leftLimit, rightLimit); //check Singular for non-zeros
        this.length = length;
    }
    
    public void incLength(int increment) {
        log.debug(entering+incLengthMthdName+"("+increment+"). old length="+length);
        if (IsIntRule2Ok(incLengthMthdName, length+increment)) { // length >= 0
            IsIntRule3Ok(incLengthMthdName, first, length+increment, rightLimit); // first+length-1 <= rightLimit
        }
        IsIntRule6Ok(this, incLengthMthdName, first, length, leftLimit, rightLimit); //check Singular for non-zeros
        this.length = length + increment;
    }
    
    public int getLeftLimit() {
        return leftLimit;
    }

    public void setLeftLimit(int leftLimit) {
        IsIntRule1Ok(setLeftLimitMthdName, leftLimit, first); // leftLimit <= first
        IsIntRule4Ok(setLeftLimitMthdName, leftLimit, rightLimit); // leftLimit <= rightLimit
        IsIntRule6Ok(this, setLeftLimitMthdName, first, length, leftLimit, rightLimit); //check Singular for non-zeros
        this.leftLimit = leftLimit;
    }

    public int getRightLimit() {
        return rightLimit;
    }

    public void setRightLimit(int rightLimit) {
        IsIntRule3Ok(setRightLimitMthdName, first, length, rightLimit); // first+length-1 <= rightLimit
        IsIntRule4Ok(setRightLimitMthdName, leftLimit, rightLimit); // leftLimit <= rightLimit
        IsIntRule6Ok(this, setRightLimitMthdName, first, length, leftLimit, rightLimit); //check Singular for non-zeros
        log.debug(setRightLimitMthdName+"(rightLimit="+rightLimit+")");
        this.rightLimit = rightLimit;
    }
    
    /**
     * @return the length
     */
    public int getLast() {
        return first+length-1;
    }
        
    @Override
    public LimitedIntRange clone() {
        return new LimitedIntRange(first, length, leftLimit, rightLimit);
        /*
        try {
            LimitedIntRange n = (LimitedIntRange) super.clone();
            n.init(first, length, leftLimit, rightLimit);
            return n;
        } catch (CloneNotSupportedException ex) {
            log.error(null, ex);
            return new LimitedIntRange(first, length, leftLimit, rightLimit);
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
                LimitedIntRange r = (LimitedIntRange)o;
                return (
                    Objects.equals(first, r.getFirst()) && 
                    Objects.equals(length, r.getLength()) && 
                    Objects.equals(leftLimit, r.getLeftLimit()) && 
                    Objects.equals(rightLimit, r.getRightLimit())
                );
                //return (hashCode() == o.hashCode());
            }
        }
    }

    @Override
    public int hashCode() {
        //return Objects.hash(first, length, leftLimit, rightLimit);
        
        int hash = 5;
        hash = 89 * hash + this.first;
        hash = 89 * hash + this.length;
        hash = 89 * hash + this.leftLimit;
        hash = 89 * hash + this.rightLimit;
        return hash;
        
    }
    
    @Override
    public String toString() {
        return "first="+first+", length="+length+", leftLimit="+leftLimit+", rightLimit="+rightLimit;
    }
    
    /**
     * Определяет, является ли текущий диапазон вырожденным
     * @return 
     */
    public boolean IsSingular() {
        return ((this == Singular) || ((first == 0) && (length == 0)));
    }
    
    /**
     * Определяет, входит ли указанная отметка в текущий диапазон
     * @param value
     * @return 
     */
    public boolean IsInbound(int value) {
        log.trace(IsInboundMthdName+"(value="+value+"). first="+first+", last="+getLast());
        return (first <= value) && (value <= getLast());
    }
    
    /**
     * Определяет, накрывает ли целиком указанный диапазон (т.е. помещается ли 
     * текущий диапазон целиком внутри указанного)
     * @param aRange
     * @return 
     */
    public boolean IsInbound(LimitedIntRange aRange) {
        if (aRange == null) {
            throw new ENullArgument(IsInboundMthdName);
        } 
        return ((aRange.getFirst() <= first) && (getLast() <= aRange.getLast()));
    }
    
    /*
    Определяет расстояние от указанной точки до до ближайшей границы диапазона
    Если точка указана за макс. границами, то ошибка
    Если точка внутри самого диапазона, то расстояние = 0
    */
    public int getMinDistance(int to) {
        log.trace(getMinDistanceMthdName+"(to="+to+")");
        IsIntRule5Ok(getMinDistanceMthdName, leftLimit, to, rightLimit); // leftLimit >= to >= rightLimit
        if (IsInbound(to)) {
            return 0;
        } else {
            int dist = Math.min(Math.abs(to - first), Math.abs(to - getLast()));
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
    public int getMaxDistance(int to) {
        log.trace(getMaxDistanceMthdName+"(to="+to+")");
        IsIntRule5Ok(getMaxDistanceMthdName, leftLimit, to, rightLimit); // leftLimit >= to >= rightLimit
        if (IsInbound(to)) {
            return 0;
        } else {
            int dist = Math.max(Math.abs(to - first), Math.abs(to - getLast()));
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
    public boolean IsOverlapped(LimitedIntRange aRange) {
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
    public LimitedIntRange Overlap(LimitedIntRange aRange) {
        log.trace(OverlapMthdName+"(aRange)");
        if (aRange == null) {
            throw new ENullArgument(OverlapMthdName);
        }
        if (IsOverlapped(aRange)) {
            log.debug("is overlapped");
            int maxStart = Math.max(first, aRange.getFirst());
            int minLast = Math.min(getLast(), aRange.getLast());
            return new LimitedIntRange(maxStart, minLast - maxStart + 1, leftLimit, rightLimit);
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
    public LimitedIntRange Add(LimitedIntRange aRange) {
        if (aRange == null) {
            throw new ENullArgument(AddMthdName);
        }
        int minStart = Math.max(leftLimit, Math.min(first, aRange.getFirst()));
        int maxLast = Math.min(Math.max(getLast(), aRange.getLast()), rightLimit);
        log.debug(AddMthdName+"(). minStart="+minStart+", maxLast="+maxLast);
        return new LimitedIntRange(minStart, maxLast - minStart + 1, leftLimit, rightLimit);
    }

    /**
     * Продлевает текущий диапазон до указанной точки. 
     * @param to
     * @return 
     */
    public LimitedIntRange Extend(int to) {
        IsIntRule5Ok(ExtendMthdName, leftLimit, to, rightLimit); // leftLimit >= to >= rightLimit
        if (IsInbound(to)) {
            return Singular;
        } else {
            int minStart = Math.max(leftLimit, Math.min(first, to));
            int maxLast = Math.min(Math.max(getLast(), to), rightLimit);
            log.debug(ExtendMthdName+"(). minStart="+minStart+", maxLast="+maxLast);
            return new LimitedIntRange(minStart, maxLast - minStart + 1, leftLimit, rightLimit);
        }
    }

    /*
    * смещает начало диапазона на указанную величину
    */
    public LimitedIntRange Shift(int value) {
        //setFirst(first+value);
        return new LimitedIntRange(Math.max(leftLimit, first+value), length, leftLimit, rightLimit);
    }
    
    /**
     * Вычитает указанный диапазон из текущего. 
     * Результирующий диапазон включает в себя часть текущего диапазона, не 
     * совпадающую с указанным (т.е за вычетом указанного).
     * Если указанный диапазон не пересекается (не имеет общего участка) с имеющимся,
     * то результатом будет текущий диапазон
     * @param aRange
     * @return 
     */
    public LimitedIntRange Sub(LimitedIntRange aRange) {
        throw new EUnsupported(); 
    /*
        //а если из охватывающего диапазона вычитают меньший, входящий в него ?
        if (aRange == null) {
            throw new ENullArgument("Sub");
        }
        if (IsOverlapped(aRange)) {
            //если диапазоны пересекаются
            int maxStart = Math.max(first, aRange.getFirst());
            int minLast = Math.min(getLast(), aRange.getLast());
            log.debug("Sub(). IsOverlapped. this.first="+first+", this.last="+getLast()+
                ", aRange.first="+aRange.getFirst()+", aRange.last="+aRange.getLast()+
                ", maxStart="+maxStart+", minLast="+minLast);
            return new LimitedIntRange(maxStart, minLast - maxStart);
        } else {
            //если диапазоны не пересекаются
            log.debug("Sub(). Not overlapped. first="+first+", length="+length);
            return new LimitedIntRange(first, length);
        }
    */
    }

    /**
     * Возвращает диапазон, который дополняет текущий диапазон до указанной точки. 
     * @param to
     * @return 
     */
    public LimitedIntRange Complement(int to) {
        log.trace(ComplementMthdName+"(to="+to+")");
        int dist = getMinDistance(to);
        if (dist < 0) {
            return new LimitedIntRange(first + dist, - dist, leftLimit, rightLimit);
        } else {
            if (dist > 0) {
                return new LimitedIntRange(first + length, dist, leftLimit, rightLimit);
            } else {
                return Singular;
            }
        }
    }

}
