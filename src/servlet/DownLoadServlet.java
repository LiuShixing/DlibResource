package servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.util.ArrayList;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class DownLoadServlet
 */
public class DownLoadServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public DownLoadServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String fileName = request.getParameter("fileName");
		String dir= request.getParameter("id");
		
		final int BUFFER_SIZE = 8192;
		
		File file=new File(MyUtil.RESOURCE_DIR+"/"+dir+"/"+fileName);
		if(!file.exists())
		{
			response.sendRedirect("ErrorPage.jsp?error=downLoadError");
			return;
		}
		ServletContext app = request.getServletContext();
		
		ArrayList<String> downingFileList = null;
		
		downingFileList =(ArrayList<String>) app.getAttribute(MyUtil.IS_DOWNING);
		if(downingFileList==null)downingFileList = new ArrayList<String>();
		
		downingFileList.add(fileName);
		app.setAttribute(MyUtil.IS_DOWNING, downingFileList);
		
		response.setHeader("content-disposition", "attachment;filename=" + URLEncoder.encode(fileName, "UTF-8"));
		FileInputStream in = new FileInputStream(file);
		OutputStream out = response.getOutputStream();
        
		int read = 0;
		byte[] buffer = new byte[BUFFER_SIZE];

		while ((read = in.read(buffer)) > -1)
		{
			out.write(buffer, 0, read);
		}
		in.close();
		out.close();
		
		downingFileList =(ArrayList<String>) app.getAttribute(MyUtil.IS_DOWNING);
		downingFileList.remove(fileName);
		app.setAttribute(MyUtil.IS_DOWNING, downingFileList);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}
