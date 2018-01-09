
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
  int MAXATTACHNAMELENGTH = 30;
  WikiContext c = WikiContext.findContext(pageContext);
  String myprogressId = c.getEngine().getProgressManager()
			.getNewProgressIdentifier();
%>
<c:set var="progressId" value="<%= c.getEngine().getProgressManager().getNewProgressIdentifier() %>" />
<div class="page-content">
<script type="text/javascript" src="scripts/jquery-3.2.1.min.js"></script>
<script type="text/javascript">
          
          var is_confirm = false;
        /*   $(window).bind('beforeunload', function(){
		    // 只有在标识变量is_confirm不为false时，才弹出确认提示
		    if(is_confirm != false)
		        return '文件尚未上传成功，确定关闭页面？';
		 }); */

          var uploadProcessTimer=null;
		  
		  function getFileUploadProcess() { 
		  var progressbar = document.getElementById('progressbar');
		  var ajaxprogress = document.getElementById('ajaxprogressId'); 
		  var uploadbutton = document.getElementById('upload');
		  var percent = document.getElementById('percent'); 
		  uploadbutton.disabled="disabled";
		  progressbar.style.visibility="visible";
		  is_confirm = true;
		              $.ajax({  
		                     type:'GET',  
		                     url:'getProgressServlet?id=${progressId}',  
		                     dataType:'text',  
		                     cache:false,  
		                     success:function(data){  
		                              
		                 
		                         if(data==100){  
		                             window.clearInterval(uploadProcessTimer);
		                             is_confirm = false;
		                         }else{  
		                             percent.innerHTML=""+data+"%";
		                             ajaxprogress.style.width=""+data+"%"; 
		                         }  
		                     }  
		             });  
		 }
		
		
		function getBrowserInfo(){
			var Sys = {};
			var ua = navigator.userAgent.toLowerCase();
			var re ="/(msie|firefox|chrome|opera|version).*?([\d.]+)/";
			var m = ua.match(re);
			Sys.browser = m[1].replace(/version/, "'safari");
			Sys.ver = m[2];
			return Sys;
		}

</script>

<wiki:UserCheck status="authenticated">
<wiki:Permission permission="upload">

<%
    String path = request.getContextPath();
    String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
   //action="<wiki:Link jsp='UploadResource.jsp' format='url' absolute='true'><wiki:Param name='progressid' value='${progressId}' /></wiki:Link>" 
   
 %>
 <form action="<%=basePath%>/UploadResource.jsp?progressid=${progressId}"
         class="accordion<wiki:HasAttachments>-close</wiki:HasAttachments>"
            id="uploadform"
        method="post"
        onsubmit="
  
              
        var file = document.getElementById('fileId');
        var title = document.getElementById('resourceTitle');
        
        if(file==null || file.value=='')
        {
           alert('请选择文件！');
           return false;
        }
        if(title==null || title.value=='')
        {
           alert('请输入资源标题！');
           return false;
        }
        
        if(file.files[0].size>3221225472)
        {
             
           alert('上传大文件时建议使用Chrome浏览器！');

        }
        
       
        uploadProcessTimer=window.setInterval('getFileUploadProcess()',100);
        
      
  
        return true;

 "
       enctype="multipart/form-data" accept-charset="<wiki:ContentEncoding/>" >

   
    <input type="hidden" name="nextpage" value="<wiki:Link context='upload' format='url'/>" />
    <input type="hidden" name="page" value="<wiki:Variable var="pagename"/>" />
    <input type="hidden" name="action" value="upload" />

    <wiki:Messages div="alert alert-danger" />
   
    
    <table class="uploadTable">
    <tr>
					<td></td>
					<td class="nomal-font">
						<%
							String error = request.getParameter("error");
							if (error != null)
							{
							  
							  if(error.equals("resourceRealNameDuplicate"))
							  {
						%>
						<div style="color:#F00">服务器已有同名资源文件！</div> 
						<%
						      }
						      else if(error.equals("resourceNameDuplicate"))
						      {
						 %>
						<div style="color:#F00">已存在该资源标题！</div> 
						<%
					     	  }
					     	}
					    %>
					</td>
				</tr>
    <tr>
	    <td class="nomal-font" width="15%">选择文件：</td>
	    <td width="90%">
		     <input class="form-control form-col-50" type="file" name="fileName" id="fileId" maxlength="80" size="60" />
		     <input type="hidden" name="author" value="<wiki:UserName />"/> 
	    </td>
    </tr>
    
    
     <tr>
	    <td class="nomal-font" >资源标题：</td>
	    <td><input class="form-control form-col-50" type="text" name="resourceTitle" id="resourceTitle" maxlength="80" size="60" /></td>
    </tr>
    
    
     <tr>
    <td class="nomal-font">资源类型：</td>
    <td>
	    <select class="form-control form-col-50" name="resourceType" id="resourceTypeId">
			<option value="0">深度学习</option>
			<option value="1">知识图谱</option>
			<option value="2">医疗</option>
			<option value="3">教育</option>
			<option value="4">其他</option>
		 </select>
    </td>
    </tr>
    
    
     <tr>
     
    <td></td> <!--  name="upload" id="upload" -->
    <td>
       <input class="btn btn-primary form-control form-col-50" type="submit" name="upload" id="upload" maxlength="80" size="60"   value="<fmt:message key='attach.add.submit'/>"/>
     
	 </td>
	 </tr>
	
	<tr> 
	 <td></td>
	 
	 <td>
        <div id="progressbar" >					
			<div class="ajaxprogress" id="ajaxprogressId"></div>			
		</div>
		<span id="percent"></span>  
     </td>
    <tr>
    
    </table>
    
 

  </form> 
  

	
</wiki:Permission>

<wiki:Permission permission="!upload">
  <div class="warning">只有授权用户才能上传资源！</div>
</wiki:Permission>
 </wiki:UserCheck>
 
  <!-- 没登陆，转到登陆界面   <wiki:Param 
         name='from' value="upload"/> -->
 <wiki:UserCheck status="notAuthenticated">
 <wiki:Permission permission="login">
 <br>
        <p>请<a href="<wiki:Link jsp='Login.jsp' format='url'><wiki:Param 
         name='redirect' value="登陆"/></wiki:Link>" 
        class="action login"
        title="<fmt:message key='actions.login.title'/>"><fmt:message key="actions.login"/></a>以上传文件。</p>
    </wiki:Permission>
 </wiki:UserCheck>
 
</div>


