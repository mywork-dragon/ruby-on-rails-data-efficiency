import re
import xml.etree.ElementTree as ET

ACCEPTABLE_BOUNDS = {
    "Suggested App": (lambda bounds: bounds and bounds[1] < 900),
    "Open In App": (lambda bounds: bounds and bounds[1] < 1600)
}

class AdBounds():

    def __init__(self, ad_xml):
        self.ad_xml = ad_xml

    def check(self):
        for text, check_function in ACCEPTABLE_BOUNDS.iteritems():
            bounds = self._get_bounds(text)
            if check_function(bounds):
                return True
        return False

    def _get_bounds(self, node_text):
        suggested_node = self._extract_node_with_text(node_text)
        if not hasattr(suggested_node, 'attrib'):
            return None
        ad_bounds=self._bounds(suggested_node.attrib['bounds'])
        return ad_bounds

    def _extract_node_with_text(self, text):
        suggested_node = {"value" : None}
        tree = ET.fromstring(self.ad_xml)
        def visit_node(e):
            if e.attrib.get('text', False):
              if e.attrib.get('text') == text:
                  suggested_node["value"] = e
        self._in_order_traversal(tree, visit_node)
        return suggested_node["value"]  

    def _bounds(self, bounds):
        return map(int, filter(lambda x: x, re.split('\,|\]|\[', bounds)))

    # Duplicate of the function ad_targeting.in_order_traversal.
    def _in_order_traversal(self, node, visitor_func):
        visitor_func(node)
        for c in node:
            self._in_order_traversal(c, visitor_func)