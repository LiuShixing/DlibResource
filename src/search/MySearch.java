package search;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.StringTokenizer;
import java.util.TreeSet;

import org.apache.log4j.Logger;
import org.apache.wiki.WikiContext;
import org.apache.wiki.WikiEngine;
import org.apache.wiki.WikiPage;
import org.apache.wiki.api.exceptions.ProviderException;
import org.apache.wiki.auth.AuthorizationManager;
import org.apache.wiki.auth.permissions.PagePermission;
import org.apache.wiki.providers.WikiPageProvider;
import org.apache.wiki.search.BasicSearchProvider;
import org.apache.wiki.search.QueryItem;
import org.apache.wiki.search.SearchMatcher;
import org.apache.wiki.search.SearchResult;
import org.apache.wiki.search.SearchResultComparator;
import org.omg.CORBA.PRIVATE_MEMBER;

import dr.DBManager;
import servlet.ResourceInfo;

public class MySearch
{
	private WikiEngine m_engine=null ;
	
	Map<String,ResourceInfo> pageMap =null;
	
	private static final Logger log = Logger.getLogger(BasicSearchProvider.class);
	
	public MySearch()
	{
		
	}
	
    @SuppressWarnings("rawtypes")
	public Collection findPages(String query, WikiContext wikiContext,WikiEngine engine,Map<String,ResourceInfo> map)
	{//System.out.println("Mysearch:1");
    	m_engine = engine;
    	pageMap = new HashMap<String, ResourceInfo>(map);
    	if(m_engine ==null || pageMap ==null)
    	{
    		log.equals("m_engine ==null || pageMap ==null");
    		
    		System.out.println("m_engine ==null || pageMap ==null");
    		return null;
    	}
    	return findPages(parseQuery(query), wikiContext);
	}

    @SuppressWarnings("rawtypes")
	private Collection findPages( QueryItem[] query, WikiContext wikiContext )
    {
        TreeSet<SearchResult> res = new TreeSet<SearchResult>( new SearchResultComparator() );

        Collection allPages = null;
        try {
            allPages = m_engine.getPageManager().getAllPages();
        } catch( ProviderException pe ) {
        	 log.error( "Unable to retrieve page list", pe );
            return null;
        }
        
        AuthorizationManager mgr = m_engine.getAuthorizationManager();

     //   System.out.println("Mysearch:2");
        
        String sql="select artid,label from article_labels";
        String sql2="select id,title from articles";
		DBManager db=new DBManager(sql);
		DBManager db2=new DBManager(sql2);
		Map<String,String> art_labels = new HashMap<>();
		Map<String,String> art_titles = new HashMap<>();
		ResultSet rs;
		ResultSet rs2;
		try
		{
			rs = db.pst.executeQuery();
			rs2 = db2.pst.executeQuery();
			while(rs.next())
			{
				art_labels.put(rs.getString(1), rs.getString(2));
			}
			while(rs2.next())
			{
				art_titles.put(rs2.getString(1), rs2.getString(2));
			}
			rs.close();
			rs2.close();
		} catch (SQLException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	
		db.close();
		db2.close();
        
        Iterator it = allPages.iterator();
        while( it.hasNext() ) {
            try {
                WikiPage page = (WikiPage) it.next();
                
             //   System.out.println("Mysearch:3 page name="+page.getName());
                if (page != null) {
                
                	
                    PagePermission pp = new PagePermission( page, PagePermission.VIEW_ACTION );
                    if( wikiContext==null || mgr.checkPermission( wikiContext.getWikiSession(), pp ) ) {
	                    String pageName = page.getName();
	                   ResourceInfo info = null;
	                   info = pageMap.get(pageName.toLowerCase());
	                   
	                   SearchResult comparison = null;
	                   if(info ==null && pageName.getBytes()[0] == '2')
	                   {
	                	   String pageContent = m_engine.getPageManager().getPageText(pageName, WikiPageProvider.LATEST_VERSION) + art_labels.get(pageName);
		                   // System.out.println("Mysearch:4 " +pageName);          
		                    
		                    comparison = matchPageContent(pageName , pageContent ,query,art_titles.get(pageName));
		                   // System.out.println("Mysearch:5");
	                   }
	                   else if(info !=null)
	                   {
		                    String pageContent = m_engine.getPageManager().getPageText(pageName, WikiPageProvider.LATEST_VERSION) +
		                    		info.getName();
		                    
		                  
		           //         System.out.println("Mysearch:4");          
		                    
		                    comparison = matchPageContent(pageName , pageContent ,query,info.getTitle());
		               //     System.out.println("Mysearch:5");
	                   }
	                   
	                 
	                    if( comparison != null ) {
	                        res.add( comparison );
	                        //System.out.println("Mysearch:6");
	                    }
	                }
	            }
            } catch( ProviderException pe ) {
            	 log.error( "Unable to retrieve page from cache", pe );
            	
            }catch( IOException ioe ) {
                log.error( "Failed to search page", ioe );
            
            }
        }
   
        return res;
    }

    public SearchResult matchPageContent( String wikiname, String pageText ,QueryItem[] query,String title) throws IOException {
        if( query == null ) {
            return null;
        }

        int[] scores = new int[ query.length ];
        BufferedReader in = new BufferedReader( new StringReader( pageText ) );
        String line = null;
        

        while( (line = in.readLine() ) != null ) {
            line = line.toLowerCase();

            for( int j = 0; j < query.length; j++ ) {
                int index = -1;

                while( (index = line.indexOf( query[j].word, index + 1 ) ) != -1 ) {
                    if( query[j].type != QueryItem.FORBIDDEN ) {
                        scores[j]++; // Mark, found this word n times
                      
                    } else {
                        // Found something that was forbidden.
                        return null;
                    }
                }
            }
        }

        //
        //  Check that we have all required words.
        //
        int totalscore = 0;

        for( int j = 0; j < scores.length; j++ ) {
            // Give five points for each occurrence
            // of the word in the wiki name.

            if( title.toLowerCase().indexOf( query[j].word ) != -1 && query[j].type != QueryItem.FORBIDDEN ) {
                scores[j] += 5;
            }

            //  Filter out pages if the search word is marked 'required'
            //  but they have no score.

            if( query[j].type == QueryItem.REQUIRED && scores[j] == 0 ) {
                return null;
            }

            //
            //  Count the total score for this page.
            //
            totalscore += scores[j];
        }

        if( totalscore > 0 ) {
            return new SearchResultImpl( wikiname, totalscore,title);
        }

        return null;
    }
    private  QueryItem[] parseQuery(String query)
    {
        StringTokenizer st = new StringTokenizer( query, " \t," );

        QueryItem[] items = new QueryItem[st.countTokens()];
        int word = 0;

       
        log.debug("Expecting "+items.length+" items");
        //
        //  Parse incoming search string
        //

        while( st.hasMoreTokens() )
        {
        	log.debug("Item "+word);
            String token = st.nextToken().toLowerCase();

            items[word] = new QueryItem();

            switch( token.charAt(0) )
            {
              case '+':
                items[word].type = QueryItem.REQUIRED;
                token = token.substring(1);
                log.debug("Required word: "+token);
                break;

              case '-':
                items[word].type = QueryItem.FORBIDDEN;
                token = token.substring(1);
                log.debug("Forbidden word: "+token);
                break;

              default:
                items[word].type = QueryItem.REQUESTED;
                log.debug("Requested word: "+token);
                break;
            }

            items[word++].word = token;
        }

        return items;
    }
    
    
 public class SearchResultImpl implements SearchResult {
    	
        int      m_score;
        WikiPage m_page;
        String   m_title;
        /**
         *  Create a new SearchResult with a given name and a score.
         *  
         *  @param name Page Name
         *  @param score A score from 0+
         */
        public SearchResultImpl( String name, int score,String title ) {
            m_page  = new WikiPage( m_engine, name );
            m_score = score;
            m_title = title;
        }

        /**
         *  Returns Wikipage for this result.
         *  @return WikiPage
         */
        public WikiPage getPage() {
            return m_page;
        }

        /**
         *  Returns a score for this match.
         *  
         *  @return Score from 0+
         */
        public int getScore() {
            return m_score;
        }

        /**
         *  Returns an empty array, since BasicSearchProvider does not support
         *  context matching.
         *  
         *  @return an empty array
         */
        public String[] getContexts() {
            String [] sarr = {m_title,m_page.getName()};
            return sarr;
        }
    }
}
