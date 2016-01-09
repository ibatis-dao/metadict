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
package shiro.dao;

import shiro.dao.AppUser;

public interface AppUserMapper {
	/*
	 * You can pass multiple parameters to a mapper method. If you do, they will be named by the literal
	 * "param" followed by their position in the parameter list by default, for example: #{param1},
	 * #{param2} etc. If you wish to change the name of the parameters (multiple only), then you can use
	 * the @Param("paramName") annotation on the parameter. 
	 **/

	AppUser getByName(String username) throws Exception;

}
