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
	System.out.println(totalRowStmt+"rankFunctionEmpListEmpList param totalRowStmt");
	
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
		SELECT 번호, 직원ID, 이름, 급여, 급여순위
		FROM
		    (SELECT rownum 번호, 직원ID, 이름, 급여, 급여순위
		FROM
		    (SELECT employee_id 직원ID, last_name 이름, salary 급여, rank() over(ORDER BY salary DESC) 급여순위
		    FROM employees))
		WHERE 번호 BETWEEN 1 AND 10;
	*/
	
	// 1) employees -> 직원ID, 이름, 급여, 급여순위 , 급여 내림차순
	// 2) rownum 번호 추가로 최종 결과에서 WHERE절을 이용하여 페이징
	String rankFunctionSql = "SELECT 번호, 직원ID, 이름, 급여, 급여순위 FROM (SELECT rownum 번호, 직원ID, 이름, 급여, 급여순위 " 
			+ " FROM (SELECT employee_id 직원ID, last_name 이름, salary 급여, rank() over(ORDER BY salary DESC) 급여순위 FROM employees)) WHERE 번호 BETWEEN ? AND ?";
	PreparedStatement rankFunctionStmt = conn.prepareStatement(rankFunctionSql);
	rankFunctionStmt.setInt(1, beginRow);
	rankFunctionStmt.setInt(2, endRow);
	ResultSet rankFunctionRs = rankFunctionStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rankFunctionRs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("번호", rankFunctionRs.getInt("번호"));
		m.put("직원ID", rankFunctionRs.getInt("직원ID"));
		m.put("이름", rankFunctionRs.getString("이름"));
		m.put("급여", rankFunctionRs.getInt("급여"));
		m.put("급여순위", rankFunctionRs.getInt("급여순위"));
		list.add(m);
	}
	System.out.println(list.size()+"rankFunctionEmpList param list.size()");
	
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
			<td>급여순위</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list) {
		%>
			<tr>
				<td><%=(Integer)m.get("번호")%></td>
				<td><%=(Integer)m.get("직원ID")%></td>
				<td><%=(String)m.get("이름")%></td>
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
				<a href="./rankFunctionEmpList.jsp?currentPage=<%=minPage-1%>">이전</a>
		<% 
				}
		
			for(int i = minPage; i <=maxPage; i=i+1) {
				if(i == currentPage) {
		%>
					<span><%=i%></span>&nbsp;
		<% 			
				} else {
		%>
				<a href="./rankFunctionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 	
				}
			}
				// 같다면 마지막 페이지
				if(minPage != maxPage) {
		%>
				<!-- maxPage + 1 -->
				<a href="./rankFunctionEmpList.jsp?currentPage=<%=maxPage+1%>">다음</a>
		<%
				}
		%>
</body>
</html>