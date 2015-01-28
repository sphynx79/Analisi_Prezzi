require 'net/ftp'
require 'fileutils'
require 'pathname'
include FileUtils

#http://snipplr.com/view/50015/

class Crawel
   attr_accessor :ftp
   def initialize(oggi)
      @giorno_flusso_d1        = (oggi+1).strftime("%G%m%d")
      @giorno_flusso_d         = (oggi).strftime("%G%m%d")
      @giorno_flusso_d_meno_7  = (oggi-7).strftime("%G%m%d")
      @ftp = nil
   end

   #Esegue il login al sito FTP e si mette in modalità passiva
   #Parameters : nil
   #Return     : nil
   def login
      @ftp = Net::FTP.new("download.mercatoelettrico.org", user="FRANCESCOGIUNTI", passwd="7T10U12G")
      @ftp.passive = true
   end

   #Scarica dal sito FTP il file associato al tipo di flusso
   #Parameters : file => "MGP_Prezzi"   (Tipo di flusso che deve scaricate)
   #Return     : "K:/.../esiti_xml/20141009/20141010MGPPrezzi.xml" (path del flusso scaricato)
   def download_file(file) 
      #name_file = "20141010MGPPrezzi.xml"
      name_file = parse_name_file file                    
      path_xml  = crea_dir_per_xml
      full_path = path_xml+name_file

      #entro dentro la directory nel server ftp
      @ftp.chdir("/MercatiElettrici/#{file}")

      #scarico nella directory corrente il file
      begin
         ftp.getbinaryfile(name_file, full_path)
         puts "Download #{name_file}"
         return full_path
      rescue
         return false
      end
   end

   #Chiude la connesione FTP 
   #Parameters : nil
   #Return     : nil
   def close_connection
      @ftp.close
   end

   #Fa il parse dal tipo di flusso, mi crea il nome del file da scaricare
   #Parameters : file => "MGP_Prezzi"   (Tipo di flusso che deve scaricate)
   #Return     : "20141010MGPPrezzi.xml" (nome del file da scaricare)
   def parse_name_file file
      #name_file =  "#{@giorno_flusso}" + "#{file.gsub "MGP_","MGP"}" + ".xml" 
      name_file = case file
                  when /OffertePubbliche/   then  "#{@giorno_flusso_d_meno_7}" + "#{file.gsub "MGP_","MGP"}"   + ".zip" 
                  when /MGP/                then  "#{@giorno_flusso_d1}"       + "#{file.gsub "MGP_","MGP"}"   + ".xml" 
                  when /MI1/                then  "#{@giorno_flusso_d1}"       + "#{file.gsub "MI1_","MI1"}"   + ".xml"
                  when /MI2/                then  "#{@giorno_flusso_d1}"       + "#{file.gsub "MI2_","MI2"}"   + ".xml"
                  when /MI3/                then  "#{@giorno_flusso_d}"        + "#{file.gsub "MI3_","MI3"}"   + ".xml" 
                  when /MI4/                then  "#{@giorno_flusso_d}"        + "#{file.gsub "MI4_","MI4"}"   + ".xml" 
                  end
      name_file
   end

   #Crea la directory che contiene il flusso e si posiziona al suo interno
   #Parameters : nil
   #Return     : "K:/.../esiti_xml/20141009" (path della directory che contiene il flusso scaricato)
   def crea_dir_per_xml
      path_xml = (Pathname.new(__dir__).parent)+"esiti_xml"+Time.now.strftime("%Y%m%d")
      path_xml.mkdir(0700) unless path_xml.exist?
      return path_xml
   end

end


# Codice Eseguito solo se lanciato direttamente da riga di comando
if __FILE__ == $0
   require 'pathname'
   require "Date"
   DATA = Date.today
   ftp = Crawel.new(DATA)
   ftp.login
   path_xml_flusso = ftp.download_file("MGP_Prezzi")
end


