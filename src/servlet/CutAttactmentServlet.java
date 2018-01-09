package servlet;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.wiki.WikiEngine;
import org.apache.wiki.providers.AbstractFileProvider;
import org.apache.wiki.providers.FileSystemProvider;

/**
 * Servlet implementation class CutAttactmentServlet
 */
public class CutAttactmentServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public CutAttactmentServlet() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		String resourceName = request.getParameter("resourceName");
		if (resourceName != null) {
            File file=new File("F:\\apache-tomcat-8.5.16\\pageDir\\"+resourceName+".txt");
            file.createNewFile();
            
            FileWriter fWriter = new FileWriter(file);
            BufferedWriter bWriter = new BufferedWriter(fWriter);
            bWriter.write("Œﬁ√Ë ˆ");
            bWriter.flush();
            bWriter.close();fWriter.close();
            
            response.sendRedirect("Wiki.jsp?page=" + resourceName + "&tag=new");
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}
