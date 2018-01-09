

<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setBundle basename="templates.default"/>

<div>
<div>
<label>标题：</label>
<input type="text" maxlength="100" size="100"/>
</div>
<wiki:Editor></wiki:Editor>
</div>