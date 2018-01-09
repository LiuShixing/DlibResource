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

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="org.apache.naming.java.javaURLContextFactory"%>
<%@page import="dr.DBManager"%>
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

	WikiSession wikiSession = wikiContext.getWikiSession();
	String user = wikiSession.getUserPrincipal().getName();
	String action = request.getParameter("action");
	String ok = request.getParameter("ok");
	String preview = request.getParameter("preview");
	String cancel = request.getParameter("cancel");
	String append = request.getParameter("append");
	String edit = request.getParameter("edit");
	String author = TextUtil.replaceEntities(findParam(pageContext,
			"author"));
	String changenote = TextUtil.replaceEntities(findParam(pageContext,
			"changenote"));
	String text = EditorManager.getEditedText(pageContext);
	String link = TextUtil.replaceEntities(findParam(pageContext,
			"link"));
	String spamhash = findParam(pageContext,
			SpamFilter.getHashFieldName(request));
	String captcha = (String) session.getAttribute("captcha");
	
//	System.out.println("Edit.jsp:editor="+edit);

	if (!wikiSession.isAuthenticated() && wikiSession.isAnonymous()
			&& author != null)
	{
		user = TextUtil.replaceEntities(findParam(pageContext, "author"));
	}

	//
	//  WYSIWYG editor sends us its greetings
	//
	String htmlText = findParam(pageContext, "htmlPageText");
	if (htmlText != null && cancel == null)
	{
		text = new HtmlStringToWikiTranslator().translate(htmlText,
				wikiContext);
	}

	WikiPage wikipage = wikiContext.getPage();
	WikiPage latestversion = wiki.getPage(pagereq);

	if (latestversion == null)
	{
		latestversion = wikiContext.getPage();

//		System.out.println("Edit.jsp: latestversion == null");
	}

	//
	//  Set the response type before we branch.
	//

	response.setContentType("text/html; charset="
			+ wiki.getContentEncoding());
	response.setHeader("Cache-control", "max-age=0");
	response.setDateHeader("Expires", new Date().getTime());
	response.setDateHeader("Last-Modified", new Date().getTime());

	//log.debug("Request character encoding="+request.getCharacterEncoding());
	//log.debug("Request content type+"+request.getContentType());
	log.debug("preview=" + preview + ", ok=" + ok);

	if (ok != null || captcha != null)
	{
		log.info("Saving page " + pagereq + ". User=" + user
				+ ", host=" + HttpUtil.getRemoteAddress(request));

		//
		//  Check for session expiry
		//

		if (!SpamFilter.checkHash(wikiContext, pageContext))
		{
			return;
		}

		WikiPage modifiedPage = (WikiPage) wikiContext.getPage()
				.clone();

		//  FIXME: I am not entirely sure if the JSP page is the
		//  best place to check for concurrent changes.  It certainly
		//  is the best place to show errors, though.

		String h = SpamFilter.getSpamHash(latestversion, request);

		if (!h.equals(spamhash))
		{
			//
			// Someone changed the page while we were editing it!
			//


				log.info("Page changed, warning user.");

				session.setAttribute(EditorManager.REQ_EDITEDTEXT,
						EditorManager.getEditedText(pageContext));
				response.sendRedirect(wiki.getURL(WikiContext.CONFLICT,
						pagereq, null, false));
				return;
		
		}

		//
		//  We expire ALL locks at this moment, simply because someone has
		//  already broken it.
		//
		PageLock lock = wiki.getPageManager().getCurrentLock(wikipage);
		wiki.getPageManager().unlockPage(lock);
		session.removeAttribute("lock-" + pagereq);

		//
		//  Set author information and other metadata
		//

		modifiedPage.setAuthor(user);

		if (changenote == null)
			changenote = (String) session.getAttribute("changenote");

		session.removeAttribute("changenote");

		if (changenote != null && changenote.length() > 0)
		{
			modifiedPage.setAttribute(WikiPage.CHANGENOTE, changenote);
		} else
		{
			modifiedPage.removeAttribute(WikiPage.CHANGENOTE);
		}

		//
		//  Figure out the actual page text
		//

		if (text == null)
		{
			throw new ServletException("No parameter text set!");
		}

		//
		//  If this is an append, then we just append it to the page.
		//  If it is a full edit, then we will replace the previous contents.
		//

		try
		{
			wikiContext.setPage(modifiedPage);

			if (captcha != null)
			{
				wikiContext.setVariable("captcha", Boolean.TRUE);
				session.removeAttribute("captcha");
			}

			if (append != null)
			{
				StringBuffer pageText = new StringBuffer(
						wiki.getText(pagereq));

				pageText.append(text);

				wiki.saveText(wikiContext, pageText.toString());
			} else
			{
				wiki.saveText(wikiContext, text);
				
	//			System.out.println("Edit.jsp:text="+text);
	//			System.out.println("Edit.jsp:TextUtil.normalizePostData( text )="+TextUtil.normalizePostData( text ));
			}
			
			
			
			String article_title = request.getParameter("article_title");
			String article_type = request.getParameter("article_type");
			String [] article_labels = request.getParameterValues("labels");
			String custom_label = request.getParameter("custom_label");
			StringBuilder sb = new StringBuilder();
			if(article_labels != null)
			{
				for(String s:article_labels)
				{
					sb.append(s);
					sb.append("/");
				}
			}
			if(custom_label != null)
			{
			
				sb.append(custom_label);
				
				for(String s:custom_label.split("/"))
				{
					if(s.equals(""))
						continue;
					
					String sql="insert into labels values(?)";
					DBManager db=new DBManager(sql);
					db.pst.setString(1,s);
					int rs=db.pst.executeUpdate();
					db.close();
				}
			}
			if(article_title!=null && article_type!=null)
			{
				//数据库操作
				String sql=null;
				sql="select * from articles where id=?";
				DBManager dbcheck=new DBManager(sql);
				dbcheck.pst.setString(1, pagereq);
				ResultSet  checkRs=dbcheck.pst.executeQuery();
				if(checkRs.next())
				{//文章已存在，更新标题和类型
					checkRs.close();
					dbcheck.close();
					
					sql="update articles set title=?,type=? where id=?";
					DBManager db=new DBManager(sql);
					db.pst.setString(1,article_title );
					db.pst.setString(2, article_type);
					db.pst.setString(3,pagereq);
					int rs=db.pst.executeUpdate();
					if(rs<=0)
						System.out.println("Edit.jsp:update article failure");
					db.close();
					
					sql = "update article_labels set label=? where artid=?";
					db=new DBManager(sql);
					db.pst.setString(1,sb.toString() );
					db.pst.setString(2,pagereq);
					rs=db.pst.executeUpdate();
					if(rs<=0)
					{
						sql = "insert into article_labels values(?,?)";
						db=new DBManager(sql);
						db.pst.setString(1,pagereq);
						db.pst.setString(2,sb.toString() );
						rs=db.pst.executeUpdate();
						db.close();
					}
					db.close();
				}
				else
				{//插入文章
					checkRs.close();
					dbcheck.close();
					
					sql="insert into articles values(?,?,?,?,?)";
					DBManager db=new DBManager(sql);
					db.pst.setString(1, pagereq);
					db.pst.setString(2, article_title);
					db.pst.setString(3, user);
					db.pst.setDate(4,  new java.sql.Date(new Date().getTime()));
					db.pst.setString(5, article_type);
					int rs=db.pst.executeUpdate();
					if(rs<=0)
						System.out.println("Edit.jsp:insert into article failure");
					db.close();
					
					sql = "insert into article_labels values(?,?)";
					db=new DBManager(sql);
					db.pst.setString(1,pagereq);
					db.pst.setString(2,sb.toString() );
					rs=db.pst.executeUpdate();
					db.close();
				
				}
				
			}
			
		} catch (DecisionRequiredException ex)
		{
			String redirect = wikiContext.getURL(WikiContext.VIEW,
					"ApprovalRequiredForPageChanges");
			response.sendRedirect(redirect);
			return;
		} catch (RedirectException ex)
		{
			// FIXME: Cut-n-paste code.
			wikiContext.getWikiSession().addMessage(ex.getMessage()); // FIXME: should work, but doesn't
			session.setAttribute("message", ex.getMessage());
			session.setAttribute(EditorManager.REQ_EDITEDTEXT,
					EditorManager.getEditedText(pageContext));
			session.setAttribute("author", user);
			session.setAttribute("link", link != null ? link : "");
			if (htmlText != null)
				session.setAttribute(EditorManager.REQ_EDITEDTEXT, text);

			session.setAttribute("changenote",
					changenote != null ? changenote : "");
			session.setAttribute(SpamFilter.getHashFieldName(request),
					spamhash);
			response.sendRedirect(ex.getRedirect());
			return;
		}

		response.sendRedirect(wiki.getViewURL(pagereq));
		return;
	} else if (preview != null)
	{
		log.debug("Previewing " + pagereq);
		session.setAttribute(EditorManager.REQ_EDITEDTEXT,
				EditorManager.getEditedText(pageContext));
		session.setAttribute("author", user);
		session.setAttribute("link", link != null ? link : "");

		if (htmlText != null)
			session.setAttribute(EditorManager.REQ_EDITEDTEXT, text);

		session.setAttribute("changenote",
				changenote != null ? changenote : "");
		response.sendRedirect(wiki.getURL(WikiContext.PREVIEW, pagereq,
				null, false));
		return;
	} else if (cancel != null)
	{
		log.debug("Cancelled editing " + pagereq);
		PageLock lock = (PageLock) session.getAttribute("lock-"
				+ pagereq);

		if (lock != null)
		{
			wiki.getPageManager().unlockPage(lock);
			session.removeAttribute("lock-" + pagereq);
		}
		response.sendRedirect(wiki.getViewURL(pagereq));
		return;
	}

	session.removeAttribute(EditorManager.REQ_EDITEDTEXT);

	log.info("Editing page " + pagereq + ". User=" + user + ", host="
			+ HttpUtil.getRemoteAddress(request));

	//
	// switch the target editor type (plain, wysiwyg-editor...) when opening the editor
	// by means of an optional url parameter &editor=plain
	//
	String editor = request.getParameter(EditorManager.PARA_EDITOR);
	if (editor != null)
	{
		log.info("Switching Editor type to: " + editor);

		Preferences prefs = (Preferences) session
				.getAttribute(Preferences.SESSIONPREFS);
		if (prefs != null)
		{
			prefs.put(EditorManager.PARA_EDITOR, editor);
		}
	}

	//
	//  Determine and store the date the latest version was changed.  Since
	//  the newest version is the one that is changed, we need to track
	//  that instead of the edited version.
	//
	String lastchange = SpamFilter.getSpamHash(latestversion, request);

	pageContext.setAttribute("lastchange", lastchange,
			PageContext.REQUEST_SCOPE);

	//
	//  Attempt to lock the page.
	//
	PageLock lock = wiki.getPageManager().lockPage(wikipage, user);

	if (lock != null)
	{
		session.setAttribute("lock-" + pagereq, lock);
	}

	String contentPage = wiki.getTemplateManager().findJSP(pageContext,
			wikiContext.getTemplate(), "ViewTemplate.jsp");
%><wiki:Include page="<%=contentPage%>" />


