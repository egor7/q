BEGIN{print "<code><pre>"}
/k\)/{print; next}
/q\)/{print; next}
/^ /{print("<b>" $0 "</b>"); next}
/^$/{print; next}
{print("<i>" $0 "</i>")}
END{print "</pre></code>"}
