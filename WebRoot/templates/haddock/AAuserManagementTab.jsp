

<%@page import="org.apache.wiki.WikiSession"%>
<%@page import="org.apache.wiki.auth.user.UserProfile"%>
<%@ page import="java.security.Principal" %>
<%@ page import="java.text.MessageFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.wiki.WikiContext" %>
<%@ page import="org.apache.wiki.auth.*" %>
<%@ page import="org.apache.wiki.auth.AuthorizationManager" %>
<%@ page import="org.apache.wiki.auth.PrincipalComparator" %>
<%@ page import="org.apache.wiki.auth.authorize.Group" %>
<%@ page import="org.apache.wiki.auth.permissions.GroupPermission" %>
<%@ page import="org.apache.wiki.auth.authorize.GroupManager" %>
<%@ page import="org.apache.wiki.preferences.Preferences" %>
<%@ page import="org.apache.log4j.*" %>
<%@ page errorPage="/Error.jsp" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<%
  WikiContext c = WikiContext.findContext( pageContext );

 

  AuthorizationManager authMgr = c.getEngine().getAuthorizationManager();
  UserManager userMgr = c.getEngine().getUserManager();

  Principal[]  users=userMgr.getUserDatabase().getWikiNames();

%>


<%-- <wiki:Include page='ProfileTab.jsp'/> --%>
<form action="<wiki:Link jsp='AddUser.jsp' format='url'><wiki:Param name='tab' value='register'/></wiki:Link>"
          id="editProfile"
       class="accordion"
      method="post" accept-charset="UTF-8">

   <h4>添加用户</h4>
   <div class="addUser">
	  <input type="hidden" name="redirect" value="<wiki:Variable var='redirect' default='' />" />
	
	<%--   <fmt:message key="prefs.errorprefix.profile" var="msg"/>
	  <wiki:Messages div="alert alert-danger" topic="profile" prefix="${msg}" /> --%>
	  
	  
<%
    String err = request.getParameter("error");
    if(err!=null)
    {
       String e="";
       if(err.equals("login_null"))e="登录名不能为空";
       if(err.equals("full_null"))e="名字不能为空";
       if(err.equals("pass_null"))e="密码不能为空";
       if(err.equals("passwordnomatch"))e="密码不匹配";
       if(err.equals("login_name_dup"))e="登录名已被占用";
       if(err.equals("full_name_dup"))e="名字已被占用";
 %>	  
    <div class="error text-align-center">
    <%=e %>
    </div>
 <%
    } 
  %>
   
	
	  <%-- Login name --%>
	  <%-- TODO:  can be simplified in case of registering a new user --%>
	  <div class="form-group">
	    <wiki:UserProfile property="canChangeLoginName">
	      <input class="form-control" type="text" name="loginname" id="loginname" size="20"
	       placeholder="<fmt:message key='prefs.loginname' />"
	             value="" />
	    </wiki:UserProfile>
	
	    <wiki:UserProfile property="!canChangeLoginName">
	      <!-- If user can't change their login name, it's because the container manages the login -->
	      <wiki:UserProfile property="new">
	        <div class="warning"><fmt:message key="prefs.loginname.cannotset.new"/></div>
	      </wiki:UserProfile>
	      <wiki:UserProfile property="exists">
	        <span class="form-control-static"><wiki:UserProfile property="loginname"/></span>
	        <div class="warning"><fmt:message key="prefs.loginname.cannotset.exists"/></div>
	      </wiki:UserProfile>
	    </wiki:UserProfile>
	  </div>
	
	  <%-- Password field; not displayed if container auth used --%>
	  <wiki:UserProfile property="canChangePassword">
	    <div class="form-group">
	       <input class="form-control" type="password" name="password" id="password" size="20"
	        placeholder="<fmt:message key='prefs.password' />"
	              value="" />
	     </div>
	     <div class="form-group">
	       <input class="form-control" type="password" name="password2" id="password2" size="20"
	        placeholder="<fmt:message key='prefs.password2' />"
	              value="" />
	       <%-- FFS: extra validation ? min size, allowed chars? password-strength js check --%>
	     </div>
	  </wiki:UserProfile>
	
	  <%-- Full name --%>
	  <div class="form-group">
	    <input class="form-control" type="text" name="fullname" id="fullname" size="20"
	     placeholder="<fmt:message key='prefs.fullname'/>"
	           value="" />
	    <p class="help-block"><fmt:message key="prefs.fullname.description"/></p>
	  </div>
	
	  <%-- E-mail --%>
	 <%--  <div class="form-group">
	    <input class="form-control" type="text" name="email" id="email" size="20"
	     placeholder="<fmt:message key='prefs.email'/>"
	           value="<wiki:UserProfile property='email' />" />
	    <p class="help-block"><fmt:message key="prefs.email.description"/></p>
	  </div> --%>
	
	  <div class="form-group">
	    <button class="btn btn-primary btn-block" type="submit" name="action" value="saveProfile">
	      <fmt:message key='prefs.newprofile' />
	    </button>
	  </div>
	
	  <hr />
	
	<%--   <p class="login-ref">
	    <fmt:message key="login.invite"/>
	    <a href="#section-login"
	      title="<fmt:message key='login.title'/>" >
	      <fmt:message key="login.heading.login"><fmt:param><wiki:Variable var="applicationname" /></fmt:param></fmt:message>
	    </a>
	  </p> --%>
  </div>
</form>

<form action="DeleteUser.jsp"
      class="hidden"
        name="deleteUserForm" id="deleteUserForm"
      method="POST" accept-charset="UTF-8">
  <input type="hidden" name="loginName" value="${group.name}" />
  <input type="submit" name="ok"
   data-modal="+ .modal"
        value="删除" />
  <div class="modal">请确认是否删除此用户！</div>
</form>


<div class="table-filter-sort-condensed-striped">

<%
  String error = request.getParameter("error");
  if( error!=null && error.equals("deletefail") )
  {
         
 %>
 <div class="error text-align-center">删除失败！</div>
 <%
  }   
  %>
  
  <table class="table">
    <thead>
      <th>登录名</th>
      <th>名字</th>
      <th>注册日期</th>
      <th>更新日期</th>
      <th>操作</th>
    </thead>
    <tbody>
    <%
    for( int i = 0; i < users.length; i++ )
    {
        String fullName = users[i].getName();
        UserProfile upf= userMgr.getUserDatabase().findByFullName(fullName);
        String loginName=upf.getLoginName();
        Date createDate = upf.getCreated();
        Date lastDate = upf.getLastModified();
    %>
    <tr class="${param.group == group.name ? 'highlight' : ''}">
      <td> <%=loginName %></td>
      <td> <%=fullName %></td>
      <td><fmt:formatDate value="<%=createDate %>" pattern="${prefs.DateFormat}" timeZone="${prefs.TimeZone}" /></td>     
      <td><fmt:formatDate value="<%=lastDate %>" pattern="${prefs.DateFormat}" timeZone="${prefs.TimeZone}" /></td>
      <td>
      <%
         if(!loginName.equals("admin"))
         {
       %>   
        <button class="btn btn-xs btn-danger" onclick="document.deleteUserForm.loginName.value ='<%=loginName %>';document.deleteUserForm.ok.click();" >
          删除
        </button>
        <%
          }
         %>
      </td>
    </tr>
    <%
 
    } /* end of for loop */
    %>
    </tbody>
  </table>
</div>
