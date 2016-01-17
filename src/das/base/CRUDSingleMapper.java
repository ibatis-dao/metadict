package das.base;

import java.io.IOException;
import java.util.List;

import org.apache.ibatis.annotations.Param;

/**
 * Template Object-Relation-Mapper interface.
 * Mostly used with CRUDSingleDAO
 * @author serg
 *
 * @param <B>
 */
public interface CRUDSingleMapper<B> {

	/*
	 * You can pass multiple parameters to a mapper method. If you do, they will be named by the literal
	 * "param" followed by their position in the parameter list by default, for example: #{param1},
	 * #{param2} etc. If you wish to change the name of the parameters (multiple only), then you can use
	 * the @Param("paramName") annotation on the parameter. 
	 **/

	List<B> getAll() throws IOException;
	int insert(B item) throws IOException;
	int update(B item) throws IOException;
	int delete(B item) throws IOException;
}
