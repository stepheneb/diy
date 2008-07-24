import java.io.*;
import javax.xml.parsers.*;

import java.util.*;
import org.w3c.dom.*;
import org.xml.sax.SAXException;


public class SDSDataMoveVerifier {
	private DocumentBuilderFactory dbf;
	private DocumentBuilder db;
	
	public SDSDataMoveVerifier() throws ParserConfigurationException {
		dbf = DocumentBuilderFactory.newInstance();
		db = this.dbf.newDocumentBuilder();
	}
	
	public boolean compareDocs(String docURI, String doc2URI) throws SAXException, IOException {
		Document doc = db.parse(docURI);
		Document doc2 = db.parse(doc2URI);
		// remove the sdsReturnAddresses nodes
		Node pf = findChildNode("sailuserdata:EPortfolio", doc);
		Node pf2 = findChildNode("sailuserdata:EPortfolio", doc2);
		Node[] sbs = findChildNodes("sessionBundles", pf);
		Node[] sbs2 = findChildNodes("sessionBundles", pf2);
		
		for (int i = 0; i < sbs.length; i++) {
			deleteChildNode("sdsReturnAddresses", sbs[i]);
		}
		
		for (int i = 0; i < sbs2.length; i++) {
			deleteChildNode("sdsReturnAddresses", sbs2[i]);
		}
		
		doc.normalize();
		doc2.normalize();
		return doc.isEqualNode(doc2);
	}
	
	private static Node findChildNode(String nodeName, Node parent) {
		NodeList childs = parent.getChildNodes();
		for (int i = 0; i < childs.getLength(); i++) {
			Node n = childs.item(i);
			if (n.getNodeName() != null && n.getNodeName().equals(nodeName)) {
				return n;
			}
		}
		return null;
	}
	
	private static void deleteChildNode(String nodeName, Node parent) {
		if (parent != null) {
			NodeList childs = parent.getChildNodes();
			for (int i = 0; i < childs.getLength(); i++) {
				Node n = childs.item(i);
				if (n.getNodeName() != null && n.getNodeName().equals(nodeName)) {
					parent.removeChild(n);
				}
			}
		}
	}
	
	private static Node[] findChildNodes(String nodeName, Node parent) {
		Vector<Node> v = new Vector<Node>();
		if (parent != null) {
			NodeList childs = parent.getChildNodes();
			for (int i = 0; i < childs.getLength(); i++) {
				Node n = childs.item(i);
				if (n.getNodeName() != null && n.getNodeName().equals(nodeName)) {
					v.add(n);
				}
			}
		}
		return v.toArray(new Node[1]);
	}
	
	/**
	 * @param args
	 * @throws ParserConfigurationException 
	 * @throws IOException 
	 * @throws SAXException 
	 */
	public static void main(String[] args) throws ParserConfigurationException, SAXException, IOException {
		SDSDataMoveVerifier dv = new SDSDataMoveVerifier();
		String filename = "/tmp/bundles.csv";
		if (args.length > 0) {
			filename = args[0];
		}
		BufferedReader r = new BufferedReader(new FileReader(filename));
		String line = null;
		int compared = 0;
		int success = 0;
		int failed = 0;
		while ((line = r.readLine()) != null) {
			if (compared % 50 == 0) {
				System.out.println("");
			}
			compared++;
			StringTokenizer st = new StringTokenizer(line, ",", false);
			String oldurl = st.nextToken();
			String newurl = st.nextToken();
			if (dv.compareDocs(oldurl, newurl)) {
				success++;
				System.out.print(".");
			} else {
				// there are differences
				failed++;
				System.out.print("x");
				System.err.println("Bundle mismatch! o: " + oldurl + ", n: " + newurl);
			}
		}
		System.out.println("");
		System.out.println("Compared: " + compared);
		System.out.println("Success:  " + success);
		System.out.println("Failed:   " + failed);
	}
}
