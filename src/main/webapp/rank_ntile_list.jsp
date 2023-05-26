<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%> 
<%
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int rowPerPage = 10;
	int beginRow = (currentPage-1) * rowPerPage + 1;
	
	//DB연결
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@127.0.0.1:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn+"접속성공");
	
	
	int totalRow = 0;
	String totalRowSql = "SELECT count(*) FROM employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	System.out.println(totalRowStmt+"rank_ntile_list param totalRowStmt");
	
	if(totalRowRs.next()) {
		totalRow = totalRowRs.getInt(1);
	}
	
	int endRow = beginRow + (rowPerPage-1);
	// endRow에 대한 에러 방지(totalRow를 넘지않도록)
	if(endRow > totalRow) {
		endRow = totalRow;
	}
	// 페이지네비게이션에 표기될 페이지 개수
	int pagePerPage = 10;
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0) {
		lastPage = lastPage + 1;
	}
	
	int minPage = ((currentPage-1) / rowPerPage) * rowPerPage + 1;
	int maxPage = minPage + (pagePerPage-1);
	// maxPage가 lagePage를 넘지 않도록
	if(maxPage > lastPage) {
		maxPage = lastPage;
	}
	
	// 1) 순위분석함수(rank(), dense_rank(), row_number()), 윈도잉절은 디폴트값 사용
	/* 
		select 번호, 성, 급여, 급여순위 from (select rownum 번호, 성, 급여, 급여순위 
        from (select first_name 성, salary 급여, rank() over(order by salary desc) 급여순위
		from employees)) 
        where 번호 between 21 and 30;
	*/
	String rankFunctionSql = "select 번호, 성, 급여, 급여순위 from (select rownum 번호, 성, 급여, 급여순위 " 
			+ " from (select first_name 성, salary 급여, rank() over(order by salary desc) 급여순위"
			+ " from employees))"
			+ " where 번호 between ? and ?";
	PreparedStatement rankFunctionStmt = conn.prepareStatement(rankFunctionSql);
	rankFunctionStmt.setInt(1, beginRow);
	rankFunctionStmt.setInt(2, endRow);
	ResultSet rankFunctionRs = rankFunctionStmt.executeQuery();
	ArrayList<HashMap<String, Object>> rankList = new ArrayList<>();
	while(rankFunctionRs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("번호", rankFunctionRs.getInt("번호"));
		m.put("성", rankFunctionRs.getString("성"));
		m.put("급여", rankFunctionRs.getInt("급여"));
		m.put("급여순위", rankFunctionRs.getInt("급여순위"));
		rankList.add(m);
	}
	System.out.println(rankList.size()+"rank_ntile_list param rankList.size()");
	
	/* 
		select 번호, 성, 급여, 급여순위 from (select rownum 번호, 성, 급여, 급여순위 
	    from (select first_name 성, salary 급여, dense_rank() over(order by salary desc) 급여순위
		from employees)) 
	    where 번호 between 21 and 30;
	*/
	
	String denseRankSql = "select 번호, 성, 급여, 급여순위 from (select rownum 번호, 성, 급여, 급여순위 " 
			+ " from (select first_name 성, salary 급여, dense_rank() over(order by salary desc) 급여순위"
			+ " from employees))"
			+ " where 번호 between ? and ?";
	PreparedStatement denseRankStmt = conn.prepareStatement(denseRankSql);
	denseRankStmt.setInt(1, beginRow);
	denseRankStmt.setInt(2, endRow);
	ResultSet denseRankRs = denseRankStmt.executeQuery();
	ArrayList<HashMap<String, Object>> denseRankList = new ArrayList<>();
	while(denseRankRs.next()) {
		HashMap<String, Object> m2 = new HashMap<>();
		m2.put("번호", denseRankRs.getInt("번호"));
		m2.put("성", denseRankRs.getString("성"));
		m2.put("급여", denseRankRs.getInt("급여"));
		m2.put("급여순위", denseRankRs.getInt("급여순위"));
		denseRankList.add(m2);
	}
	System.out.println(denseRankList.size()+"rank_ntile_list param denseRankList.size()");
	
	/* 
		select 번호, 성, 급여, 급여순위 from (select rownum 번호, 성, 급여, 급여순위 
	    from (select first_name 성, salary 급여, row_number() over(order by salary desc) 급여순위
		from employees)) 
	    where 번호 between 21 and 30;
	*/
	
	String rowNumberSql = "select 번호, 성, 급여, 급여순위 from (select rownum 번호, 성, 급여, 급여순위 " 
			+ " from (select first_name 성, salary 급여, row_number() over(order by salary desc) 급여순위"
			+ " from employees))"
			+ " where 번호 between ? and ?";
	PreparedStatement rowNumberStmt = conn.prepareStatement(rowNumberSql);
	rowNumberStmt.setInt(1, beginRow);
	rowNumberStmt.setInt(2, endRow);
	ResultSet rowNumberRs = rowNumberStmt.executeQuery();
	ArrayList<HashMap<String, Object>> rowNumberList = new ArrayList<>();
	while(rowNumberRs.next()) {
		HashMap<String, Object> m3 = new HashMap<>();
		m3.put("번호", rowNumberRs.getInt("번호"));
		m3.put("성", rowNumberRs.getString("성"));
		m3.put("급여", rowNumberRs.getInt("급여"));
		m3.put("급여순위", rowNumberRs.getInt("급여순위"));
		rowNumberList.add(m3);
	}
	System.out.println(rowNumberList.size()+"rank_ntile_list param rowNumberList.size()");
	
	// 2) 비율분석함수(ntile)
	/* 
		select 번호, 성, 급여, 급여등급 from (select rownum 번호, 성, 급여, 급여등급 
        from (select first_name 성, salary 급여, ntile(5) over(order by salary desc) 급여등급
		from employees)) 
        where 번호 between 41 and 50;
	*/
	
	String ntileSql = "select 번호, 성, 급여, 급여등급 from (select rownum 번호, 성, 급여, 급여등급 " 
			+ " from (select first_name 성, salary 급여, ntile(5) over(order by salary desc) 급여등급"
			+ " from employees))"
			+ " where 번호 between ? and ?";
	PreparedStatement ntileStmt = conn.prepareStatement(ntileSql);
	ntileStmt.setInt(1, beginRow);
	ntileStmt.setInt(2, endRow);
	ResultSet ntileRs = ntileStmt.executeQuery();
	ArrayList<HashMap<String, Object>> ntileList = new ArrayList<>();
	while(ntileRs.next()) {
		HashMap<String, Object> m4 = new HashMap<>();
		m4.put("번호", ntileRs.getInt("번호"));
		m4.put("성", ntileRs.getString("성"));
		m4.put("급여", ntileRs.getInt("급여"));
		m4.put("급여등급", ntileRs.getInt("급여등급"));
		ntileList.add(m4);
	}
	System.out.println(ntileList.size()+"rank_ntile_list param ntileList.size()");
%>  
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h2>rank()</h2>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>성</td>
			<td>급여</td>
			<td>급여순위</td>
		</tr>
		<%
			for(HashMap<String, Object> m : rankList) {
		%>
			<tr>
				<td><%=(Integer)m.get("번호")%></td>
				<td><%=(String)m.get("성")%></td>
				<td><%=(Integer)m.get("급여")%></td>
				<td><%=(Integer)m.get("급여순위")%></td>
			</tr>
		<%
			}
		%>
	</table>
		<%
			// 1페이지 뒤로갈 필요없음
			if(minPage > 1) {
		%>
				<a href="./rank_ntile_list.jsp?currentPage=<%=minPage-1%>">이전</a>
		<% 
				}
		
			for(int i = minPage; i <=maxPage; i=i+1) {
				if(i == currentPage) {
		%>
					<span><%=i%></span>&nbsp;
		<% 			
				} else {
		%>
				<a href="./rank_ntile_list.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 	
				}
			}
				// 같다면 마지막 페이지
				if(minPage != maxPage) {
		%>
				<!-- maxPage + 1 -->
				<a href="./rank_ntile_list.jsp?currentPage=<%=maxPage+1%>">다음</a>
		<%
				}
		%>
		
	<h2>dense_rank()</h2>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>성</td>
			<td>급여</td>
			<td>급여순위</td>
		</tr>
		<%
			for(HashMap<String, Object> m2 : denseRankList) {
		%>
			<tr>
				<td><%=(Integer)m2.get("번호")%></td>
				<td><%=(String)m2.get("성")%></td>
				<td><%=(Integer)m2.get("급여")%></td>
				<td><%=(Integer)m2.get("급여순위")%></td>
			</tr>
		<%
			}
		%>
	</table>
		<%
			// 1페이지 뒤로갈 필요없음
			if(minPage > 1) {
		%>
				<a href="./rank_ntile_list.jsp?currentPage=<%=minPage-1%>">이전</a>
		<% 
				}
		
			for(int i = minPage; i <=maxPage; i=i+1) {
				if(i == currentPage) {
		%>
					<span><%=i%></span>&nbsp;
		<% 			
				} else {
		%>
				<a href="./rank_ntile_list.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 	
				}
			}
				// 같다면 마지막 페이지
				if(minPage != maxPage) {
		%>
				<!-- maxPage + 1 -->
				<a href="./rank_ntile_list.jsp?currentPage=<%=maxPage+1%>">다음</a>
		<%
				}
		%>
		
	<h2>row_number()</h2>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>성</td>
			<td>급여</td>
			<td>급여순위</td>
		</tr>
		<%
			for(HashMap<String, Object> m3 : rowNumberList) {
		%>
			<tr>
				<td><%=(Integer)m3.get("번호")%></td>
				<td><%=(String)m3.get("성")%></td>
				<td><%=(Integer)m3.get("급여")%></td>
				<td><%=(Integer)m3.get("급여순위")%></td>
			</tr>
		<%
			}
		%>
	</table>
		<%
			// 1페이지 뒤로갈 필요없음
			if(minPage > 1) {
		%>
				<a href="./rank_ntile_list.jsp?currentPage=<%=minPage-1%>">이전</a>
		<% 
				}
		
			for(int i = minPage; i <=maxPage; i=i+1) {
				if(i == currentPage) {
		%>
					<span><%=i%></span>&nbsp;
		<% 			
				} else {
		%>
				<a href="./rank_ntile_list.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 	
				}
			}
				// 같다면 마지막 페이지
				if(minPage != maxPage) {
		%>
				<!-- maxPage + 1 -->
				<a href="./rank_ntile_list.jsp?currentPage=<%=maxPage+1%>">다음</a>
		<%
				}
		%>
		
	<h2>ntile()</h2>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>성</td>
			<td>급여</td>
			<td>급여등급</td>
		</tr>
		<%
			for(HashMap<String, Object> m4 : ntileList) {
		%>
			<tr>
				<td><%=(Integer)m4.get("번호")%></td>
				<td><%=(String)m4.get("성")%></td>
				<td><%=(Integer)m4.get("급여")%></td>
				<td><%=(Integer)m4.get("급여등급")%></td>
			</tr>
		<%
			}
		%>
	</table>
		<%
			// 1페이지 뒤로갈 필요없음
			if(minPage > 1) {
		%>
				<a href="./rank_ntile_list.jsp?currentPage=<%=minPage-1%>">이전</a>
		<% 
				}
		
			for(int i = minPage; i <=maxPage; i=i+1) {
				if(i == currentPage) {
		%>
					<span><%=i%></span>&nbsp;
		<% 			
				} else {
		%>
				<a href="./rank_ntile_list.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 	
				}
			}
				// 같다면 마지막 페이지
				if(minPage != maxPage) {
		%>
				<!-- maxPage + 1 -->
				<a href="./rank_ntile_list.jsp?currentPage=<%=maxPage+1%>">다음</a>
		<%
				}
		%>
</body>
</html>