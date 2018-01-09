

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
	//String pagereq = wikiContext.getName();
	
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
	
	String id;
	UUID uuid=UUID.randomUUID();
	id=uuid.toString().toLowerCase();
	id="2"+id;

	WikiPage wikipage = wikiContext.getPage();
	wikipage.setAuthor(user);
	wikipage.removeAttribute(WikiPage.CHANGENOTE);
	wikiContext.setPage(wikipage);

	wiki.saveText(wikiContext, "");
	
	response.sendRedirect("Edit.jsp?tag=write&page="+id);
%>


