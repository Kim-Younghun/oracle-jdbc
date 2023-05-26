<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%> 
<%

	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}

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
	System.out.println(totalRowStmt+"windowsFunctionEmpList param totalRowStmt");
	
	if(totalRowRs.next()) {
		totalRow = totalRowRs.getInt(1);
	}
	
	int rowPerPage = 10;
	int beginRow = (currentPage-1) * rowPerPage + 1;
	int endRow = beginRow + (rowPerPage-1);
	// endRow에 대한 에러 방지
	if(endRow > totalRow) {
		endRow = totalRow;
	}
	
	int pagePerPage = 10;
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0) {
		lastPage = lastPage + 1;
	}
	
	int minPage = ((currentPage-1) / rowPerPage) * rowPerPage + 1;
	int maxPage = minPage + (pagePerPage-1);
	if(maxPage > lastPage) {
		maxPage = lastPage;
	}
	
	/*
		SELECT 번호, 직원ID, 이름, 급여, 전체급여평균, 전체급여합계, 전체사원수
		FROM (SELECT rownum 번호, employee_id 직원ID, last_name 이름, salary 급여, 
	    round(avg(salary) over()) 전체급여평균,
	    sum(salary) over() 전체급여합계,
	    count(*) over() 전체사원수 FROM employees)
		WHERE 번호 BETWEEN 1 AND 10;
	*/
	
	String windowsFunctionSql = "SELECT 번호, 직원ID, 이름, 급여, 전체급여평균, 전체급여합계, 전체사원수 FROM (SELECT rownum 번호, employee_id 직원ID, last_name 이름, salary 급여,"
		+ " round(avg(salary) over()) 전체급여평균, sum(salary) over() 전체급여합계, count(*) over() 전체사원수 FROM employees) WHERE 번호 BETWEEN ? AND ?";
	PreparedStatement windowsFunctionStmt = conn.prepareStatement(windowsFunctionSql);
	windowsFunctionStmt.setInt(1, beginRow);
	windowsFunctionStmt.setInt(2, endRow);
	ResultSet windowsFunctionRs = windowsFunctionStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(windowsFunctionRs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("번호", windowsFunctionRs.getInt("번호"));
		m.put("직원ID", windowsFunctionRs.getInt("직원ID"));
		m.put("이름", windowsFunctionRs.getString("이름"));
		m.put("급여", windowsFunctionRs.getInt("급여"));
		m.put("전체급여평균", windowsFunctionRs.getInt("전체급여평균"));
		m.put("전체급여합계", windowsFunctionRs.getInt("전체급여합계"));
		m.put("전체사원수", windowsFunctionRs.getInt("전체사원수"));
		list.add(m);
	}
	System.out.println(list.size()+"windowsFunctionEmpList param list.size()");
%>   
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>직원ID</td>
			<td>이름</td>
			<td>급여</td>
			<td>전체급여평균</td>
			<td>전체급여합계</td>
			<td>전체사원수</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list) {
		%>
			<tr>
				<td><%=(Integer)m.get("번호")%></td>
				<td><%=(Integer)m.get("직원ID")%></td>
				<td><%=(String)m.get("이름")%></td>
				<td><%=(Integer)m.get("급여")%></td>
				<td><%=(Integer)m.get("전체급여평균")%></td>
				<td><%=(Integer)m.get("전체급여합계")%></td>
				<td><%=(Integer)m.get("전체사원수")%></td>
			</tr>
		<%
			}
		%>
	</table>
		<%
			if(minPage > 1) {
		%>
				<a href="./windowsFunctionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
		<% 
				}
		
			for(int i = minPage; i <=maxPage; i=i+1) {
				if(i == currentPage) {
		%>
					<span><%=i%></span>&nbsp;
		<% 			
				} else {
		%>
				<a href="./windowsFunctionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 	
				}
			}
				if(minPage != maxPage) {
		%>
				<!-- maxPage + 1 -->
				<a href="./windowsFunctionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
		<%
				}
		%>
</body>
</html>