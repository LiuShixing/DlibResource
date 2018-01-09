

<%@page import="org.apache.wiki.attachment.AttachmentManager"%>
<%@page import="org.apache.wiki.util.TextUtil"%>
<%@page import="org.apache.commons.fileupload.FileUploadException"%>
<%@page import="org.apache.commons.io.IOUtils"%>
<%@page import="java.io.ObjectOutputStream"%>
<%@page import="org.apache.wiki.util.FileUtil"%>
<%@page import="java.io.OutputStream"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="java.io.ObjectInputStream"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.File"%>
<%@page import="servlet.MyUtil"%>
<%@page import="servlet.ResourceInfo"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="org.apache.commons.fileupload.ProgressListener"%>
<%@page import="org.apache.wiki.ui.progress.ProgressItem"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.FileItemFactory"%>
<%@page import="org.apache.wiki.api.exceptions.RedirectException"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@page import="servlet.UploadServlet"%>
<%@page import="java.io.IOException"%>
<%@ page import="org.apache.log4j.*" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.preferences.Preferences" %>
<%@ page errorPage="/Error.jsp" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>

<%! 
  
  
    private static final String[] WINDOWS_DEVICE_NAMES = { "con", "prn", "nul",
			"aux", "lpt1", "lpt2", "lpt3", "lpt4", "lpt5", "lpt6", "lpt7",
			"lpt8", "lpt9", "com1", "com2", "com3", "com4", "com5", "com6",
			"com7", "com8", "com9" };

	private static final int BUFFER_SIZE = 8192;


	private WikiEngine m_engine;
	private static final Logger log = Logger.getLogger(UploadServlet.class);

	private static final String HDR_VERSION = "version";
	// private static final String HDR_NAME = "page";

	/** Default expiry period is 1 day */
	protected static final long DEFAULT_EXPIRY = 1 * 24 * 60 * 60 * 1000;

	/**
	 * The maximum size that an attachment can be.
	 */
	private int m_maxSize = Integer.MAX_VALUE;
	
	
	private String[] m_allowedPatterns;

	private String[] m_forbiddenPatterns;
    
    public void myInit(ServletConfig config) throws ServletException
	{
		String tmpDir;

		m_engine = WikiEngine.getInstance(config);
		Properties props = m_engine.getWikiProperties();

		tmpDir = m_engine.getWorkDir() + File.separator + "attach-tmp";
		
		m_maxSize = TextUtil.getIntegerProperty(props,
				AttachmentManager.PROP_MAXSIZE, Integer.MAX_VALUE);

		String allowed = TextUtil.getStringProperty(props,
				AttachmentManager.PROP_ALLOWEDEXTENSIONS, null);

		if (allowed != null && allowed.length() > 0)
			m_allowedPatterns = allowed.toLowerCase().split("\\s");
		else
			m_allowedPatterns = new String[0];

		String forbidden = TextUtil.getStringProperty(props,
				AttachmentManager.PROP_FORDBIDDENEXTENSIONS, null);

		if (forbidden != null && forbidden.length() > 0)
			m_forbiddenPatterns = forbidden.toLowerCase().split("\\s");
		else
			m_forbiddenPatterns = new String[0];

		File f = new File(tmpDir);
		if (!f.exists())
		{
			f.mkdirs();
		} else if (!f.isDirectory())
		{
			log.fatal("A file already exists where the temporary dir is supposed to be: "
					+ tmpDir + ".  Please remove it.");
		}

		log.debug("UploadServlet initialized. Using " + tmpDir
				+ " for temporary storage.");
	}
    
    private static class UploadListener extends ProgressItem implements
			ProgressListener
	{
		public long m_currentBytes;
		public long m_totalBytes;

		public void update(long recvdBytes, long totalBytes, int item)
		{
			m_currentBytes = recvdBytes;
			m_totalBytes = totalBytes;
		}

		public int getProgress()
		{
			return (int) (((float) m_currentBytes / m_totalBytes) * 100 + 0.5);
		}
	}
	
    String upload(HttpServletRequest req) throws RedirectException,
			IOException
	{	//System.out.println("UploadResource.jsp: -2");
		String msg = "";
		String attName = "(unknown)";
	/* 	String errorPage = m_engine.getURL(WikiContext.ERROR, "", null, false); // If
																				// something
																				// bad
																				// happened,
																				// Upload
																				// should
																				// be
																				// able
																				// to
																				// take
																				// care
																				// of
																				// most
																		// stuff */
	    String errorPage = "ErrorPage.jsp?error=upload-error";
		String nextPage = errorPage;
//System.out.println("UploadResource.jsp: -1");
		String progressId = req.getParameter("progressid");

		// Check that we have a file upload request
		if (!ServletFileUpload.isMultipartContent(req))
		{
			throw new RedirectException("Not a file upload", errorPage);
		}

		HttpSession session=req.getSession();
		String error="";
		try
		{
			FileItemFactory factory = new DiskFileItemFactory();

			// Create the context _before_ Multipart operations, otherwise
			// strict servlet containers may fail when setting encoding.
			WikiContext context = m_engine.createContext(req,
					WikiContext.ATTACH);

			UploadListener pl = new UploadListener();

			m_engine.getProgressManager().startProgress(pl, progressId);

			ServletFileUpload upload = new ServletFileUpload(factory);
			upload.setHeaderEncoding("UTF-8");
			
			/* if (!context.hasAdminPermissions())
			{
				upload.setFileSizeMax(m_maxSize);
			} */
//System.out.println("UploadResource.jsp: 0");
			upload.setProgressListener(pl);
			List<FileItem> items = upload.parseRequest(req);
//System.out.println("UploadResource.jsp: 1");
			String wikipage = null;
			String changeNote = null;
			// FileItem actualFile = null;
			List<FileItem> fileItems = new java.util.ArrayList<FileItem>();

			String resourceTitle = null;
			String resourceFileName = null;
		
			Map<String,ResourceInfo> mp=null;
	
			String author=null;
			long size = 0;
			String resourceType=null;
			for (FileItem item : items)
			{
	
				if (item.isFormField())
				{
					
					if (item.getFieldName().equals("page"))
					{
						//
						// FIXME: Kludge alert. We must end up with the parent
						// page name,
						// if this is an upload of a new revision
						//

						wikipage = item.getString("UTF-8");
						int x = wikipage.indexOf("/");
               
						if (x != -1)
							wikipage = wikipage.substring(0, x);
					}else if(item.getFieldName().equals("author"))
					{
						author = item.getString("UTF-8");
						
					}
					 else if (item.getFieldName().equals("resourceTitle"))
					{

						/*
						 * 新建一個page，resourceName
						 */
						 resourceTitle = item.getString("UTF-8");
						
						
					}else if (item.getFieldName().equals("resourceType")) {
						resourceType = item.getString("UTF-8");
					}
				} else
				{
					
					fileItems.add(item);
					size = item.getSize();
					resourceFileName = item.getName();
				}
			}
		
/***********************************************************************************************/
//System.out.println("UploadResource.jsp: 2");
			ServletContext application = req.getServletContext();
			synchronized(MyUtil.mapLock)
			{ 
				
				if(application !=null)
				{
					mp=(Map<String,ResourceInfo>) application.getAttribute(MyUtil.RESOURCE_INFO_MP);
				}
				
				if(mp==null)
				{
					File file =new File(MyUtil.PAGE_DIR+"fileNameMap.ob");
					if(file.exists())
					{
				        FileInputStream in;
				        try {
				            in = new FileInputStream(file);
				            ObjectInputStream objIn=new ObjectInputStream(in);
				            mp=(Map<String,ResourceInfo>)objIn.readObject();
				            objIn.close();
				 //           System.out.println("read object success!");
				        } catch (IOException e) {
				   //         System.out.println("read object failed");
				            e.printStackTrace();
				        } catch (ClassNotFoundException e) {
				            e.printStackTrace();
				        }
					}
				}
				if (mp == null)
				{
					mp=new HashMap<String,ResourceInfo>();
				}
			
				if (resourceTitle != null)
				{
					Iterator<Entry<String,ResourceInfo>> it = mp.entrySet().iterator(); 
					while(it.hasNext())
					{
						Map.Entry<String,ResourceInfo> entry = it.next();
						
					
						
						if(entry.getValue()!=null && entry.getValue().getTitle()!=null && entry.getValue().getTitle().equals(resourceTitle))
						{
							nextPage = "Home.jsp?tag=upload&error=resourceNameDuplicate";
							return nextPage;
						}
						
						if(entry.getValue()!=null && entry.getValue().getName()!=null && entry.getValue().getName().equals(resourceFileName))
						{
							nextPage = "Home.jsp?tag=upload&error=resourceRealNameDuplicate";
							return nextPage;
						}
					}		
				}
			} 
			
			
			
			
			
/***********************************************************************************************/			
			

			if (fileItems.size() == 0)
			{
				throw new RedirectException("Broken file upload", errorPage);

			} else
			{
				
				for (FileItem actualFile : fileItems)
				{

					String filename = actualFile.getName();
					long fileSize = actualFile.getSize();
					InputStream in = actualFile.getInputStream();

				
					try
					{
						/*executeUpload(context, in, filename, nextPage,
								wikipage, changeNote, fileSize);*/
						
						
						String[] splitpath = filename.split("[/\\\\]");
						filename = splitpath[splitpath.length - 1];
						
						String ID;
						UUID uuid=UUID.randomUUID();
                       	ID=uuid.toString().toLowerCase();
                       	ID="1"+ID;
						
						File dir=new File(MyUtil.RESOURCE_DIR, ID);
						if( !dir.mkdir() )
						{
						    System.out.println("UploadResource.jsp:create dir fail   dir="+MyUtil.RESOURCE_DIR+ID);
						    return errorPage;
						}
						File newfile = new File( MyUtil.RESOURCE_DIR+"/"+ID, filename );

      
						OutputStream out = new FileOutputStream(newfile);
//System.out.println("UploadResource.jsp: 3");
                        FileUtil.copyContents( in, out );
						
     //     System.out.println("UploadResource.jsp: 4");             
                        synchronized(this)
            			{
                        	ResourceInfo info = new ResourceInfo();                         			
                			
                			info.setTitle(resourceTitle);
                        	info.setName(filename);
                        	info.setSize(fileSize);
                        	info.setID(ID);
                        	info.setTime(new Date());
                        	info.setAuthor(author);
                        	info.setType(resourceType);
                        	
	                        mp.put(ID.toLowerCase(), info);   //*************************************应该等上传成功再写入
	        				
	        				//保存mp
	        				application.setAttribute(MyUtil.RESOURCE_INFO_MP, mp);
	
	        				File f = new File(MyUtil.PAGE_DIR+"fileNameMap.ob");
	        				FileOutputStream outs = null;
	        		        try {
	        		            outs = new FileOutputStream(f);
	        		            ObjectOutputStream objOut=new ObjectOutputStream(outs);
	        		            objOut.writeObject(mp);
	        		            objOut.flush();
	        		            objOut.close();
	        	//	            System.out.println("write object success!");
	        		        } catch (IOException e) {
	        	//	            System.out.println("write object failed");
	        		            e.printStackTrace();
	        		        }
	        		        if(outs!=null)outs.close();
            			}
                        
        				//nextPage = "Wiki.jsp?page="+ID+"&tag=new";
        				//nextPage = "Edit.jsp?page="+ID+"&tag=new";
        				nextPage = "AddPage.jsp?page="+ID;
        
						
					} finally
					{
						IOUtils.closeQuietly(in);
					}

				}
			}

		} catch (IOException e)
		{
			// Show the submit page again, but with a bit more
			// intimidating output.
			msg = "上传失败！ " ;
			log.warn(msg + " (attachment: " + attName + ")", e);
		
			throw e;
		} catch (FileUploadException e)
		{
			// Show the submit page again, but with a bit more
			// intimidating output.
			msg = "上传失败：连接中断！";
			log.warn(msg + " (attachment: " + attName + ")", e);
		
			throw new IOException(msg, e);
		} finally
		{
			m_engine.getProgressManager().stopProgress(progressId);
			// FIXME: In case of exceptions should absolutely
			// remove the uploaded file.
		}


		return nextPage;
	}
%>

<%
   myInit(getServletConfig());
   
   try
		{

			String nextPage = upload(request);
			request.getSession().removeAttribute("msg");
			response.sendRedirect(nextPage);

			// res.sendRedirect("Wiki.jsp?page=" + resourceName + "&tag=new");
		} catch (RedirectException e)
		{
			WikiSession sess = WikiSession.getWikiSession(m_engine, request);
			sess.addMessage(e.getMessage());

			request.getSession().setAttribute("msg", e.getMessage());
			response.sendRedirect(e.getRedirect());
		}
   
   
 %>

