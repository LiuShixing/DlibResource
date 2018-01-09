
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.auth.*" %>
<%@ page import="org.apache.wiki.ui.progress.*" %>
<%@ page import="org.apache.wiki.auth.permissions.*" %>
<%@ page import="java.security.Permission" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ page import="org.apache.wiki.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<!doctype html>
<html lang="en">
  <head>

  <title>上传图片</title>
  <wiki:Include page="commonheader.jsp"/>
  <meta name="robots" content="noindex,nofollow" />
</head>

<body class="context-<wiki:Variable var='requestcontext' />">

 

<%
  int MAXATTACHNAMELENGTH = 30;
  WikiContext c = WikiContext.findContext(pageContext);
  String pageNameString = request.getParameter("page");
%>
<c:set var="progressId" value="<%= c.getEngine().getProgressManager().getNewProgressIdentifier() %>" />
<div class="page-content">
<div class="page">
<wiki:Content/>
</div>
</div>

   

</body>

</html>