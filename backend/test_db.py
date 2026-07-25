import os
import sys
from dotenv import load_dotenv

# Ensure backend path is in python path
sys.path.insert(0, os.path.dirname(__file__))

load_dotenv()

from app import app, db, AuditHistory

def test_supabase_connection():
    print("[*] Testing Supabase PostgreSQL Database Connection...")
    db_url = os.getenv('DATABASE_URL')
    if not db_url:
        print("[!] ERROR: DATABASE_URL is not set in environment!")
        return False

    print(f"[*] DATABASE_URL host: {db_url.split('@')[-1] if '@' in db_url else 'Hidden'}")

    with app.app_context():
        try:
            # 1. Create tables
            db.create_all()
            print("[+] Successfully connected & initialized table schemas in Supabase!")

            # 2. Query total count
            count_before = AuditHistory.query.count()
            print(f"[+] Current Audit History records in DB: {count_before}")

            # 3. Insert test audit log
            test_audit = AuditHistory(
                filename="connection_test.csv",
                total_analyzed=100,
                risk_profile="Low",
                findings_count=1
            )
            db.session.add(test_audit)
            db.session.commit()
            print(f"[+] Successfully inserted test audit log (ID: {test_audit.id})!")

            # 4. Retrieve inserted record
            fetched = AuditHistory.query.get(test_audit.id)
            print(f"[+] Retrieved record from Supabase: {fetched.to_dict()}")

            # 5. Clean up test record
            db.session.delete(fetched)
            db.session.commit()
            print(f"[+] Cleaned up test audit log.")

            print("[==>] SUPABASE POSTGRESQL VERIFICATION SUCCESSFUL!")
            return True
        except Exception as e:
            err_msg = str(e)
            print(f"[!] Database connection/query error: {err_msg[:300]}")
            if "could not translate host name" in err_msg or "Name or service not known" in err_msg:
                print("\n[NOTE ON SUPABASE POSTGRESQL DNS RESOLUTION]")
                print("1. Direct Supabase hostnames (db.[project-ref].supabase.co) use IPv6-only DNS AAAA records.")
                print("2. If your local network/ISP does not support IPv6, update DATABASE_URL in .env to use the Supabase Pooler (IPv4) host:")
                print("   postgresql://postgres.[project-ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres")
                print("3. Or verify that your Supabase project is active (not paused in Supabase Dashboard).")
            return False

if __name__ == "__main__":
    success = test_supabase_connection()
    sys.exit(0 if success else 1)
