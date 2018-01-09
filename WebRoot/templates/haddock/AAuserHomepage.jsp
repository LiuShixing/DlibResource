<%@page import="java.text.DateFormat"%>
<%@page import="servlet.Article"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="dr.DBManager"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="servlet.MyUtil"%>
<%@page import="servlet.ResourceInfo"%>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.auth.*" %>
<%@ page import="org.apache.wiki.ui.progress.*" %>
<%@ page import="org.apache.wiki.auth.permissions.*" %>
<%@ page import="java.security.Permission" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<%
String fullName=request.getParameter("fullName");
HttpSession sess=request.getSession();
if(fullName!=null)
{
	sess.setAttribute("curr_view_user", fullName);
}
else{
	fullName=(String)sess.getAttribute("curr_view_user");
}
String pid=request.getParameter("page");
String href="Wiki.jsp?page="+pid+"&fullName="+fullName;
 %>

<div class="page-content">
	<div class="tabs">
	
	<h3 id="section-homepage">个人主页</h3>
	<wiki:Include page="AAhomepageTab.jsp" />
	
	<wiki:UserCheck status="authenticated">
		  <h3 id="section-personalUpload"><a href="<%=href %>#section-personalUpload" >上传的资源</a></h3>
		<wiki:Include page="AApersonalUploadTab.jsp" />
	</wiki:UserCheck>
		
		
	<wiki:UserCheck status="notAuthenticated">
		  <wiki:Permission permission="login">
			
				<h3 id="section-personalUpload"><a href="<wiki:Link jsp='Login.jsp' format='url'><wiki:Param 
			         name='redirect' value="登陆"/></wiki:Link>" 
			        class="action login"
			        title="登陆以查看资源" >上传的资源</a></h3>
			
		</wiki:Permission>
	</wiki:UserCheck>
	
	<h3 id="section-personalArticles"><a href="<%=href %>#section-personalArticles" >发表的文章</a></h3>
	<wiki:Include page="AApersonalArticlesTab.jsp" />

	</div>
</div>