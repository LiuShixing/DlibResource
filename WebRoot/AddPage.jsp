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

<%@ page import="org.apache.log4j.*"%>
<%@ page import="java.util.*"%>
<%@ page import="org.apache.wiki.*"%>
<%@ page import="org.apache.wiki.util.HttpUtil"%>
<%@ page import="org.apache.wiki.api.exceptions.RedirectException"%>
<%@ page import="org.apache.wiki.filters.SpamFilter"%>
<%@ page import="org.apache.wiki.htmltowiki.HtmlStringToWikiTranslator"%>
<%@ page import="org.apache.wiki.preferences.Preferences"%>
<%@ page import="org.apache.wiki.ui.EditorManager"%>
<%@ page import="org.apache.wiki.util.TextUtil"%>
<%@ page import="org.apache.wiki.workflow.DecisionRequiredException"%>
<%@ page errorPage="/Error.jsp"%>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki"%>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>

<%!Logger log = Logger.getLogger("JSPWiki");

	String findParam(PageContext ctx, String key)
	{
		ServletRequest req = ctx.getRequest();

		String val = req.getParameter(key);

		if (val == null)
		{
			val = (String) ctx.findAttribute(key);
		}

		return val;
	}%>

<%
	WikiEngine wiki = WikiEngine.getInstance(getServletConfig());
	// Create wiki context and check for authorization
	WikiContext wikiContext = wiki.createContext(request,
			WikiContext.EDIT);
	if (!wiki.getAuthorizationManager()
			.hasAccess(wikiContext, response))
		return;
	String pagereq = wikiContext.getName();
	
//	System.out.println("AddPage:pagereq="+pagereq);

	WikiSession wikiSession = wikiContext.getWikiSession();
	String user = wikiSession.getUserPrincipal().getName();
	
	String author = TextUtil.replaceEntities(findParam(pageContext,
			"author"));
	String changenote = TextUtil.replaceEntities(findParam(pageContext,
			"changenote"));

	String link = TextUtil.replaceEntities(findParam(pageContext,
			"link"));
	String spamhash = findParam(pageContext,
			SpamFilter.getHashFieldName(request));
	String captcha = (String) session.getAttribute("captcha");
	

	if (!wikiSession.isAuthenticated() && wikiSession.isAnonymous()
			&& author != null)
	{
		user = TextUtil.replaceEntities(findParam(pageContext, "author"));

	}

	WikiPage wikipage = wikiContext.getPage();
	wikipage.setAuthor(user);
	wikipage.removeAttribute(WikiPage.CHANGENOTE);
	wikiContext.setPage(wikipage);

	wiki.saveText(wikiContext, "无资源描述。");
	
	response.sendRedirect("Wiki.jsp?page="+pagereq);
%>


