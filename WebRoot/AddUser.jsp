
<%@page import="org.apache.wiki.workflow.Decision"%>
<%@page import="org.apache.wiki.workflow.Workflow"%>
<%@page import="org.apache.wiki.workflow.Fact"%>
<%@page import="org.apache.wiki.auth.UserManager.SaveUserProfileTask"%>
<%@page import="org.apache.wiki.workflow.Task"%>
<%@page import="org.apache.wiki.workflow.WorkflowBuilder"%>
<%@ page import="org.apache.log4j.*" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="java.security.Principal" %>
<%@ page import="org.apache.wiki.auth.*" %>
<%@ page import="org.apache.wiki.auth.login.CookieAssertionLoginModule" %>
<%@ page import="org.apache.wiki.auth.login.CookieAuthenticationLoginModule" %>
<%@ page import="org.apache.wiki.auth.user.DuplicateUserException" %>
<%@ page import="org.apache.wiki.auth.user.UserProfile" %>
<%@ page import="org.apache.wiki.i18n.InternationalizationManager" %>
<%@ page import="org.apache.wiki.preferences.Preferences" %>
<%@ page import="org.apache.wiki.tags.WikiTagBase" %>
<%@ page import="org.apache.wiki.workflow.DecisionRequiredException" %>
<%@ page errorPage="/Error.jsp" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<%!
    Logger log = Logger.getLogger("JSPWiki");
%>
<%
    WikiEngine wiki = WikiEngine.getInstance( getServletConfig() );
    AuthenticationManager mgr = wiki.getAuthenticationManager();
    WikiContext wikiContext = wiki.createContext( request, WikiContext.LOGIN );
    pageContext.setAttribute( WikiTagBase.ATTR_CONTEXT,
                              wikiContext,
                              PageContext.REQUEST_SCOPE );
    WikiSession wikiSession = wikiContext.getWikiSession();
    ResourceBundle rb = Preferences.getBundle( wikiContext, "CoreResources" );

    String redirectPage =  "UserPreferences.jsp?tab=groups#section-users";
    wikiContext.setVariable( "redirect", redirectPage);

    UserManager userMgr = wiki.getUserManager();
    UserProfile profile = userMgr.parseProfile( wikiContext );
     
    
    {
       String loginName=profile.getLoginName();
       if(loginName==null || loginName.trim().equals(""))
       { 
           response.sendRedirect("UserPreferences.jsp?error=login_null&tab=groups#section-users");
           return;
       }
       
       String fullName=profile.getFullname();
       if(fullName==null || fullName.trim().equals(""))
       { 
           response.sendRedirect("UserPreferences.jsp?error=full_null&tab=groups#section-users");
           return;
       }
       
       String password=profile.getPassword();
       if(password==null || password.trim().equals("") )
       {
           response.sendRedirect("UserPreferences.jsp?error=pass_null&tab=groups#section-users");
           return;
       }
       String password2 = request.getParameter("password2");
        if ( !password.equals( password2 ) )
        {
           response.sendRedirect("UserPreferences.jsp?error=passwordnomatch&tab=groups#section-users");
           return;
        }
    }
    

    // If no errors, save the profile now & refresh the principal set!
    if ( wikiSession.getMessages( "profile" ).length == 0 )
    {
       
            // userMgr.setUserProfile( wikiSession, profile );
       //     CookieAssertionLoginModule.setUserCookie( response, profile.getFullname() );
	        boolean newProfile = profile.isNew();
	
	       
	        UserProfile otherProfile;
	        try
	        {
	            otherProfile = wiki.getUserManager().getUserDatabase().findByLoginName( profile.getLoginName() );
	            if ( otherProfile != null && !otherProfile.equals( profile ) )
	            {
	                 response.sendRedirect("UserPreferences.jsp?error=login_name_dup&tab=groups#section-users");
                     return;
	            }
	        }
	        catch( NoSuchPrincipalException e )
	        {
	        }
	        try
	        {
	            otherProfile = wiki.getUserManager().getUserDatabase().findByFullName( profile.getFullname() );
	            if ( otherProfile != null && !otherProfile.equals( profile ) )
	            {
	                response.sendRedirect("UserPreferences.jsp?error=full_name_dup&tab=groups#section-users");
                    return;
	            }
	        }
	        catch( NoSuchPrincipalException e )
	        {
	        }
	      
	      
	      
            WorkflowBuilder builder = WorkflowBuilder.getBuilder( wiki );
            Principal submitter = wikiSession.getUserPrincipal();
            Task completionTask = new SaveUserProfileTask( wiki, wikiSession.getLocale() );
     
	       final String SAVE_APPROVER             = "workflow.createUserProfile";
	       final String SAVED_PROFILE             = "userProfile";
	       final String SAVE_DECISION_MESSAGE_KEY = "decision.createUserProfile";
	       final String FACT_SUBMITTER            = "fact.submitter";
	       final String PREFS_LOGIN_NAME          = "prefs.loginname";
	       final String PREFS_FULL_NAME           = "prefs.fullname";
	       final String PREFS_EMAIL               = "prefs.email";
            // Add user profile attribute as Facts for the approver (if required)
            boolean hasEmail = profile.getEmail() != null;
            Fact[] facts = new Fact[ hasEmail ? 4 : 3];
            facts[0] = new Fact( PREFS_FULL_NAME, profile.getFullname() );
            facts[1] = new Fact( PREFS_LOGIN_NAME, profile.getLoginName() );
            facts[2] = new Fact( FACT_SUBMITTER, submitter.getName() );
            if ( hasEmail )
            {
                facts[3] = new Fact( PREFS_EMAIL, profile.getEmail() );
            }
            Workflow workflow = builder.buildApprovalWorkflow( submitter,
                                                               SAVE_APPROVER,
                                                               null,
                                                               SAVE_DECISION_MESSAGE_KEY,
                                                               facts,
                                                               completionTask,
                                                               null );

            workflow.setAttribute( SAVED_PROFILE, profile );
            wiki.getWorkflowManager().start(workflow);

	              
        }
   
    response.sendRedirect(redirectPage);

%>