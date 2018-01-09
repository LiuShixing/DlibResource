<%--
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
--%>

<%@page import="org.apache.commons.lang.ObjectUtils.Null"%>
<%@page import="servlet.MyUtil"%>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<div class="page-content">

<h4><%=LocaleSupport.getLocalizedMessage(pageContext, "conflict.oops.title")%></h4>
  <div class="error">
    <fmt:message key="conflict.oops" />
  </div>
  
  <%
      
      String pageTitle=(String)pageContext.getAttribute(MyUtil.CONFLICT_PAGE_NAME);
      if(pageTitle==null)pageTitle="";
   %>
  <fmt:message key="conflict.goedit" >
    <fmt:param><wiki:EditLink><%=pageTitle %></wiki:EditLink></fmt:param>
  </fmt:message>

<h4><%=LocaleSupport.getLocalizedMessage(pageContext, "conflict.modified")%></h4>

  <pre><%=pageContext.getAttribute("conflicttext",PageContext.REQUEST_SCOPE)%></pre>

<h4><%=LocaleSupport.getLocalizedMessage(pageContext, "conflict.yourtext")%></h4>

  <pre><%=pageContext.getAttribute("usertext",PageContext.REQUEST_SCOPE)%></pre>

</div>