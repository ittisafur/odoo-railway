FROM odoo:16.0

ARG LOCALE=en_US.UTF-8
ENV LANGUAGE=${LOCALE}
ENV LC_ALL=${LOCALE}
ENV LANG=${LOCALE}

USER 0
RUN apt-get -y update && apt-get install -y --no-install-recommends \
  locales \
  netcat-openbsd \
  tesseract-ocr \
  tesseract-ocr-eng \
  tesseract-ocr-ben \
  libtesseract-dev \
  python3-pip \
  && locale-gen ${LOCALE} \
  && rm -rf /var/lib/apt/lists/*

# Install Python packages for OCR
RUN pip3 install pyocr PyPDF2

# Create addons directory if it doesn't exist
RUN mkdir -p /mnt/extra-addons

WORKDIR /app
COPY --chmod=755 entrypoint.sh ./

# Switch back to odoo user for security
USER odoo

ENTRYPOINT ["/bin/sh"]
CMD ["entrypoint.sh"]
