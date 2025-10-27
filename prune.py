#!/usr/bin/env python3
"""
URL Redaction Script for YAML and Terraform Files
Scans for URLs and replaces them with placeholders to protect internal domains.
"""

import os
import re
import argparse
from pathlib import Path

# Configuration
PLACEHOLDER_DOMAIN = "example.com"
REDACTION_MAP = {
    # You can add specific domain mappings here if needed
    # "internal.company.com": "example.internal",
}

# Common internal TLDs and patterns to redact
INTERNAL_PATTERNS = [
    r'\.local',
    r'\.internal', 
    r'\.corp',
    r'\.priv',
    r'\.lan',
    r'\.home',
    r'\.localdomain',
    r'\.ru',
    # Add your company-specific internal domains here
    # r'\.yourcompany-internal',
]

def should_redact_url(url):
    """
    Determine if a URL should be redacted based on internal patterns.
    """
    url_lower = url.lower()
    
    # Check against specific domain mappings
    for internal_domain in REDACTION_MAP.keys():
        if internal_domain in url_lower:
            return True
    
    # Check against internal TLD patterns
    for pattern in INTERNAL_PATTERNS:
        if re.search(pattern, url_lower):
            return True
    
    return False

def redact_url(url):
    """
    Replace internal URLs with placeholder while preserving structure.
    """
    try:
        # Simple redaction: replace domain but keep path structure
        if '://' in url:
            # For full URLs: http://internal.domain/path -> http://example.internal/path
            protocol, rest = url.split('://', 1)
            if '/' in rest:
                domain, path = rest.split('/', 1)
                path = '/' + path
            else:
                domain, path = rest, ''
            
            return f"{protocol}://{PLACEHOLDER_DOMAIN}{path}"
        else:
            # For domain-only patterns: internal.domain -> example.internal
            if '/' in url:
                domain, path = url.split('/', 1)
                return f"{PLACEHOLDER_DOMAIN}/{path}"
            else:
                return PLACEHOLDER_DOMAIN
    except Exception:
        # Fallback: if anything goes wrong, return simple placeholder
        return PLACEHOLDER_DOMAIN

def process_file(file_path):
    """
    Process a single file and redact internal URLs.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Enhanced URL pattern to catch various formats
        url_patterns = [
            # Full URLs with protocols
            r'https?://[a-zA-Z0-9.-]+(?::\d+)?(?:/[a-zA-Z0-9._~:/?#@!$&\'()*+,;=%\-]*)?',
            r'ftp://[a-zA-Z0-9.-]+(?::\d+)?(?:/[a-zA-Z0-9._~:/?#@!$&\'()*+,;=%\-]*)?',
            # Domain patterns (common in configs)
            r'[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?::\d+)?(?:/[a-zA-Z0-9._~:/?#@!$&\'()*+,;=%\-]*)?',
            # Kubernetes/ArgoCD style service references
            r'[a-zA-Z0-9-]+\.[a-zA-Z-]+\.svc\.cluster\.local(?::\d+)?(?:/[a-zA-Z0-9._~:/?#@!$&\'()*+,;=%\-]*)?',
        ]
        
        redacted_count = 0
        for pattern in url_patterns:
            def replace_match(match):
                url = match.group(0)
                if should_redact_url(url):
                    nonlocal redacted_count
                    redacted_count += 1
                    return redact_url(url)
                return url
            
            content = re.sub(pattern, replace_match, content)
        
        # Write back only if changes were made
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return redacted_count
        return 0
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return 0

def main():
    parser = argparse.ArgumentParser(description='Redact internal URLs from YAML and Terraform files')
    parser.add_argument('--directory', '-d', default='.', 
                       help='Directory to scan (default: current directory)')
    parser.add_argument('--dry-run', action='store_true',
                       help='Show what would be changed without modifying files')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Verbose output')
    
    args = parser.parse_args()
    
    target_dir = Path(args.directory)
    if not target_dir.exists():
        print(f"Error: Directory {target_dir} does not exist")
        return
    
    # File patterns to scan
    patterns = ['*.yaml', '*.yml', '*.tf']
    
    total_files = 0
    total_redactions = 0
    
    print(f"Scanning directory: {target_dir.absolute()}")
    print(f"Internal patterns: {INTERNAL_PATTERNS}")
    print(f"Placeholder domain: {PLACEHOLDER_DOMAIN}")
    if args.dry_run:
        print("DRY RUN - No files will be modified")
    print("-" * 50)
    
    for pattern in patterns:
        for file_path in target_dir.rglob(pattern):
            if args.verbose:
                print(f"Checking: {file_path}")
            
            if args.dry_run:
                # In dry-run mode, just check and report
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    # Check for internal URLs without modifying
                    for url_pattern in [
                        r'https?://[a-zA-Z0-9.-]+(?::\d+)?(?:/[a-zA-Z0-9._~:/?#@!$&\'()*+,;=%\-]*)?',
                        r'[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?::\d+)?(?:/[a-zA-Z0-9._~:/?#@!$&\'()*+,;=%\-]*)?'
                    ]:
                        for match in re.finditer(url_pattern, content):
                            if should_redact_url(match.group(0)):
                                print(f"WOULD REDACT: {file_path}")
                                print(f"  {match.group(0)} -> {redact_url(match.group(0))}")
                                total_redactions += 1
                                break
                        else:
                            continue
                        break
                    
                    total_files += 1
                    
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")
            else:
                # Actual processing
                redactions = process_file(file_path)
                if redactions > 0:
                    print(f"Redacted {redactions} URLs in: {file_path}")
                    total_redactions += redactions
                    total_files += 1
    
    print("-" * 50)
    if args.dry_run:
        print(f"DRY RUN COMPLETE: Found {total_redactions} URLs to redact across {total_files} files")
    else:
        print(f"REDACTION COMPLETE: Redacted {total_redactions} URLs across {total_files} files")
    
    if total_redactions > 0 and not args.dry_run:
        print(f"\n⚠️  IMPORTANT: Always verify the changes with 'git diff' before committing!")
        print("   Review to ensure no public URLs were accidentally redacted.")

if __name__ == "__main__":
    main()
