# Public repositories

An issue, comment, commit or PR in a public repo is public for good: editing it leaves the old text in its visible history. Sanitize every one before it leaves this machine.

1. Read the title, body and commit messages as a stranger would. Replace anything that ties them to the owner: names, email addresses, hostnames, IP addresses, private URLs, account and device IDs, and the contents of their documents or records. Describe the shape instead ("a receipt with two line items", "the home server"). Apply any public-repo rules in the project's `CLAUDE.md` too.
2. Run this on the file, and clear every hit, keeping one only when it points at public material such as the repo itself or published docs:

   ```sh
   grep -nE '([0-9]{1,3}\.){3}[0-9]{1,3}|https?://|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+' <file>
   ```

3. When the problem depends on what was in a real document or record, show the user the sanitized text and file it only once they approve.

If something personal reaches a filed issue or PR anyway, tell the user at once: whether to delete that revision or the whole thing is their call.
